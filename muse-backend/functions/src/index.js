'use strict';

const express = require('express');
const {onRequest} = require('firebase-functions/v2/https');
const {initializeApp} = require('firebase-admin/app');
const {getAuth} = require('firebase-admin/auth');
const {getFirestore} = require('firebase-admin/firestore');
const V = require('./logic');

initializeApp();
const db = getFirestore();
const app = express();
app.disable('x-powered-by');
app.use(express.json({limit:'64kb'}));
const run = fn => (req,res,next) => Promise.resolve().then(()=>fn(req,res)).catch(next);
const user = req => db.collection('users').doc(req.uid);
const col = (req,name) => user(req).collection(name);
const view = doc => ({id:doc.id,...doc.data()});
const now = () => new Date().toISOString();
const id = value => V.ids([value],'id',1)[0];

function audit(batch, req, action, target, targetId) {
  batch.create(col(req,'auditLogs').doc(), {action,target,targetId,at:now(),uid:req.uid});
}
async function commit(req, action, target, targetId, op) {
  const batch=db.batch(); op(batch); audit(batch,req,action,target,targetId); await batch.commit();
}
async function requireDoc(ref) { const snap=await ref.get(); if (!snap.exists) V.fail('Resource not found',404); return snap; }
async function requireAll(req, collection, itemIds) {
  if (!itemIds.length) return [];
  const snaps=await db.getAll(...itemIds.map(itemId=>col(req,collection).doc(itemId)));
  if (snaps.some(s=>!s.exists)) V.fail(`One or more ${collection} entries were not found`,422);
  return snaps.map(view);
}
async function availableItems(req,itemIds) {
  const items=await requireAll(req,'wardrobe',itemIds);
  if (items.some(i=>i.archived)) V.fail('Archived wardrobe items cannot be selected',422);
  return items;
}
function page(req) {
  const limit=Number(req.query.limit || 50);
  if (!Number.isInteger(limit) || limit<1 || limit>100) V.fail('limit must be 1..100');
  const after=req.query.after === undefined ? null : id(req.query.after);
  return {limit,after};
}
async function list(req,res,name) {
  const {limit,after}=page(req);
  let q=col(req,name).orderBy('__name__').limit(limit+1);
  if (after) q=q.startAfter(col(req,name).doc(after));
  const snapshot=await q.get();
  const docs=snapshot.docs.slice(0,limit);
  res.json({data:docs.map(view),nextCursor:snapshot.size>limit ? docs.at(-1).id : null});
}

app.get('/health',(_req,res)=>res.json({status:'ok'}));
app.use('/v1',(req,res,next)=>Promise.resolve().then(async()=>{
  const match=/^Bearer (\S+)$/i.exec(req.get('authorization') || '');
  if (!match) V.fail('Firebase ID token required',401);
  try { req.uid=(await getAuth().verifyIdToken(match[1],true)).uid; }
  catch { V.fail('Invalid or revoked Firebase ID token',401); }
}).then(()=>next(),next));

app.get('/v1/me',run(async (req,res)=>{
  const auth=await getAuth().getUser(req.uid);
  res.json({uid:req.uid,email:auth.email || null,displayName:auth.displayName || null});
}));

app.post('/v1/wardrobe',run(async (req,res)=>{
  const data=V.wardrobe(req.body);
  const ref=col(req,'wardrobe').doc();
  if (data.imagePath && !data.imagePath.startsWith(`users/${req.uid}/wardrobe/${ref.id}/`)) V.fail('Upload image after creating the item');
  const record={...data,color:data.color??null,season:data.season??'all',occasions:data.occasions??[],imagePath:data.imagePath??null,notes:data.notes??null,archived:data.archived??false,createdAt:now(),updatedAt:now()};
  await commit(req,'create','wardrobe',ref.id,b=>b.create(ref,record));
  res.status(201).json({id:ref.id,...record});
}));
app.get('/v1/wardrobe',run((req,res)=>list(req,res,'wardrobe')));
app.get('/v1/wardrobe/:id',run(async(req,res)=>res.json(view(await requireDoc(col(req,'wardrobe').doc(id(req.params.id)))))));
app.patch('/v1/wardrobe/:id',run(async(req,res)=>{
  const ref=col(req,'wardrobe').doc(id(req.params.id)); await requireDoc(ref);
  const data=V.wardrobe(req.body,true);
  if (data.imagePath && !data.imagePath.startsWith(`users/${req.uid}/wardrobe/${ref.id}/`)) V.fail('imagePath must belong to this item');
  if (data.archived === true && !(await col(req,'outfits').where('itemIds','array-contains',ref.id).limit(1).get()).empty) V.fail('Item is used by an outfit',409);
  await commit(req,'update','wardrobe',ref.id,b=>b.update(ref,{...data,updatedAt:now()}));
  res.json(view(await ref.get()));
}));
app.delete('/v1/wardrobe/:id',run(async(req,res)=>{
  const ref=col(req,'wardrobe').doc(id(req.params.id)); await requireDoc(ref);
  if (!(await col(req,'outfits').where('itemIds','array-contains',ref.id).limit(1).get()).empty) V.fail('Item is used by an outfit',409);
  await commit(req,'delete','wardrobe',ref.id,b=>b.delete(ref)); res.status(204).end();
}));

app.post('/v1/outfits',run(async(req,res)=>{
  const data=V.outfit(req.body); await availableItems(req,data.itemIds);
  const ref=col(req,'outfits').doc();
  const record={...data,occasion:data.occasion??null,season:data.season??null,notes:data.notes??null,createdAt:now(),updatedAt:now()};
  await commit(req,'create','outfit',ref.id,b=>b.create(ref,record)); res.status(201).json({id:ref.id,...record});
}));
app.get('/v1/outfits',run((req,res)=>list(req,res,'outfits')));
app.get('/v1/outfits/:id',run(async(req,res)=>res.json(view(await requireDoc(col(req,'outfits').doc(id(req.params.id)))))));
app.patch('/v1/outfits/:id',run(async(req,res)=>{
  const ref=col(req,'outfits').doc(id(req.params.id)); await requireDoc(ref);
  const data=V.outfit(req.body,true); if (data.itemIds) await availableItems(req,data.itemIds);
  await commit(req,'update','outfit',ref.id,b=>b.update(ref,{...data,updatedAt:now()})); res.json(view(await ref.get()));
}));
app.delete('/v1/outfits/:id',run(async(req,res)=>{
  const ref=col(req,'outfits').doc(id(req.params.id)); await requireDoc(ref);
  if (!(await col(req,'planner').where('outfitId','==',ref.id).limit(1).get()).empty || !(await col(req,'packingLists').where('outfitIds','array-contains',ref.id).limit(1).get()).empty) V.fail('Outfit is used by a plan or packing list',409);
  await commit(req,'delete','outfit',ref.id,b=>b.delete(ref)); res.status(204).end();
}));
app.get('/v1/recommendations',run(async(req,res)=>{
  const occasion=req.query.occasion, season=req.query.season;
  if (occasion && typeof occasion !== 'string' || season && typeof season !== 'string') V.fail('Invalid filter');
  const snapshot=await col(req,'wardrobe').limit(501).get();
  if (snapshot.size>500) V.fail('Recommendation limit exceeded (500 wardrobe items)',422);
  res.json({data:V.recommend(snapshot.docs.map(view),{occasion,season}),method:'rule-based-v1'});
}));

app.put('/v1/planner/:date',run(async(req,res)=>{
  const day=V.date(req.params.date), data=V.planner(req.body);
  await requireDoc(col(req,'outfits').doc(data.outfitId));
  const ref=col(req,'planner').doc(day), old=await ref.get();
  const record={...data,date:day,createdAt:old.exists ? old.data().createdAt : now(),updatedAt:now()};
  await commit(req,old.exists?'update':'create','planner',day,b=>b.set(ref,record)); res.json(record);
}));
app.get('/v1/planner',run(async(req,res)=>{
  const from=V.date(req.query.from,'from'),to=V.date(req.query.to,'to');
  if (to<from) V.fail('to must be on or after from');
  const days=Math.round((Date.parse(to)-Date.parse(from))/86400000);
  if (days>366) V.fail('Date range cannot exceed 366 days');
  const snap=await col(req,'planner').orderBy('__name__').startAt(from).endAt(to).get();
  res.json({data:snap.docs.map(view)});
}));
app.delete('/v1/planner/:date',run(async(req,res)=>{
  const day=V.date(req.params.date),ref=col(req,'planner').doc(day); await requireDoc(ref);
  await commit(req,'delete','planner',day,b=>b.delete(ref)); res.status(204).end();
}));

app.post('/v1/packing-lists',run(async(req,res)=>{
  const data=V.packing(req.body);
  const outfits=await requireAll(req,'outfits',data.outfitIds);
  const allIds=[...new Set([...outfits.flatMap(o=>o.itemIds),...data.extraItemIds])];
  const items=await availableItems(req,allIds);
  const ref=col(req,'packingLists').doc();
  const record={...data,items:V.packingItems(outfits,items,data.extraItemIds),createdAt:now(),updatedAt:now()};
  await commit(req,'create','packingList',ref.id,b=>b.create(ref,record)); res.status(201).json({id:ref.id,...record});
}));
app.get('/v1/packing-lists',run((req,res)=>list(req,res,'packingLists')));
app.get('/v1/packing-lists/:id',run(async(req,res)=>res.json(view(await requireDoc(col(req,'packingLists').doc(id(req.params.id)))))));
app.patch('/v1/packing-lists/:id/items/:itemId',run(async(req,res)=>{
  V.exact(req.body,['packed']); if (typeof req.body.packed !== 'boolean') V.fail('Invalid packed');
  const ref=col(req,'packingLists').doc(id(req.params.id)),itemId=id(req.params.itemId);
  const snap=await requireDoc(ref),items=snap.data().items;
  if (!items.some(i=>i.itemId===itemId)) V.fail('Item not found in packing list',404);
  const next=items.map(i=>i.itemId===itemId?{...i,packed:req.body.packed}:i);
  await commit(req,'update','packingList',ref.id,b=>b.update(ref,{items:next,updatedAt:now()}));
  res.json(view(await ref.get()));
}));
app.delete('/v1/packing-lists/:id',run(async(req,res)=>{
  const ref=col(req,'packingLists').doc(id(req.params.id)); await requireDoc(ref);
  await commit(req,'delete','packingList',ref.id,b=>b.delete(ref)); res.status(204).end();
}));

app.use((_req,_res,next)=>next(Object.assign(new Error('Route not found'),{status:404})));
app.use((err,req,res,_next)=>{
  const status=err.status || (err.type==='entity.too.large' ? 413 : err instanceof SyntaxError && 'body' in err ? 400 : 500);
  if (status>=500) console.error('API error', {path:req.path,code:err.code,message:err.message});
  res.status(status).json({error:{code:status===500?'internal':status===401?'unauthorized':status===404?'not_found':status===409?'conflict':'invalid_request',message:status>=500?'Internal server error':err.message}});
});

exports.api=onRequest({region:'asia-south1',cors:false,maxInstances:10},app);
