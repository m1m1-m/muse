'use strict';

const CATEGORIES = ['top', 'bottom', 'dress', 'outerwear', 'shoes', 'accessory'];
const SEASONS = ['spring', 'summer', 'autumn', 'winter', 'all'];
const OCCASIONS = ['casual', 'work', 'formal', 'sport', 'travel'];

function fail(message, status = 400) { const e = new Error(message); e.status = status; throw e; }
function object(value) { if (!value || typeof value !== 'object' || Array.isArray(value)) fail('Expected a JSON object'); return value; }
function exact(value, allowed) { object(value); for (const k of Object.keys(value)) if (!allowed.includes(k)) fail(`Unknown field: ${k}`); }
function string(value, field, max = 100) {
  if (typeof value !== 'string' || !value.trim() || value.trim().length > max) fail(`Invalid ${field}`);
  return value.trim();
}
function optionalString(value, field, max = 100) { return value === undefined || value === null ? null : string(value, field, max); }
function enumValue(value, choices, field) { if (!choices.includes(value)) fail(`Invalid ${field}`); return value; }
function stringList(value, field, max = 30) {
  if (!Array.isArray(value) || value.length > max || value.some(x => typeof x !== 'string' || !x.trim() || x.length > 80)) fail(`Invalid ${field}`);
  const v = value.map(x => x.trim()); if (new Set(v).size !== v.length) fail(`Duplicate ${field}`); return v;
}
function ids(value, field, max = 30) {
  const v = stringList(value, field, max);
  if (v.some(x => !/^[A-Za-z0-9_-]{1,128}$/.test(x))) fail(`Invalid ${field}`);
  return v;
}
function date(value, field = 'date') {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value) || Number.isNaN(Date.parse(`${value}T00:00:00Z`)) || new Date(`${value}T00:00:00Z`).toISOString().slice(0,10) !== value) fail(`Invalid ${field}; use YYYY-MM-DD`);
  return value;
}
function wardrobe(input, partial = false) {
  exact(input, ['name','category','color','season','occasions','imagePath','notes','archived']);
  const x = {};
  if ('name' in input || !partial) x.name = string(input.name, 'name');
  if ('category' in input || !partial) x.category = enumValue(input.category, CATEGORIES, 'category');
  if ('color' in input) x.color = optionalString(input.color, 'color', 40);
  if ('season' in input) x.season = enumValue(input.season, SEASONS, 'season');
  if ('occasions' in input) x.occasions = stringList(input.occasions, 'occasions', 5).map(o => enumValue(o, OCCASIONS, 'occasion'));
  if ('imagePath' in input) {
    if (input.imagePath !== null && (typeof input.imagePath !== 'string' || !/^users\/[A-Za-z0-9_-]+\/wardrobe\/[A-Za-z0-9_-]+\/[A-Za-z0-9_-]+\.(jpg|jpeg|png|webp)$/.test(input.imagePath))) fail('Invalid imagePath');
    x.imagePath = input.imagePath;
  }
  if ('notes' in input) x.notes = optionalString(input.notes, 'notes', 500);
  if ('archived' in input) { if (typeof input.archived !== 'boolean') fail('Invalid archived'); x.archived = input.archived; }
  if (partial && !Object.keys(x).length) fail('No fields to update');
  return x;
}
function outfit(input, partial = false) {
  exact(input, ['name','itemIds','occasion','season','notes']); const x = {};
  if ('name' in input || !partial) x.name = string(input.name, 'name');
  if ('itemIds' in input || !partial) { x.itemIds = ids(input.itemIds, 'itemIds'); if (!x.itemIds.length) fail('itemIds cannot be empty'); }
  if ('occasion' in input) x.occasion = enumValue(input.occasion, OCCASIONS, 'occasion');
  if ('season' in input) x.season = enumValue(input.season, SEASONS, 'season');
  if ('notes' in input) x.notes = optionalString(input.notes, 'notes', 500);
  if (partial && !Object.keys(x).length) fail('No fields to update'); return x;
}
function planner(input) {
  exact(input, ['outfitId','notes']); return {outfitId: ids([input.outfitId], 'outfitId', 1)[0], notes: 'notes' in input ? optionalString(input.notes,'notes',500) : null};
}
function packing(input) {
  exact(input, ['name','startDate','endDate','outfitIds','extraItemIds']);
  const x = {name:string(input.name,'name'), startDate:date(input.startDate,'startDate'), endDate:date(input.endDate,'endDate'), outfitIds:ids(input.outfitIds,'outfitIds',30), extraItemIds:ids(input.extraItemIds || [],'extraItemIds',30)};
  if (x.endDate < x.startDate) fail('endDate must be on or after startDate');
  if (!x.outfitIds.length && !x.extraItemIds.length) fail('Choose an outfit or an extra item');
  return x;
}
function recommend(items, {occasion, season} = {}) {
  if (occasion) enumValue(occasion,OCCASIONS,'occasion');
  if (season) enumValue(season,SEASONS,'season');
  const candidates = items.filter(i => !i.archived && (!season || i.season === 'all' || i.season === season) && (!occasion || !i.occasions?.length || i.occasions.includes(occasion)));
  const rank = i => (occasion && i.occasions?.includes(occasion) ? 2 : 0) + (season && i.season === season ? 1 : 0);
  const by = c => candidates.filter(i => i.category === c).sort((a,b) => rank(b)-rank(a) || a.id.localeCompare(b.id)).slice(0,12);
  const tops=by('top'), bottoms=by('bottom'), dresses=by('dress'), shoes=by('shoes');
  const combinations = [];
  for (const top of tops) for (const bottom of bottoms) for (const shoe of shoes) combinations.push([top,bottom,shoe]);
  for (const dress of dresses) for (const shoe of shoes) combinations.push([dress,shoe]);
  return combinations.map(group => ({itemIds:group.map(i=>i.id), score: group.reduce((n,i) => n + (occasion && i.occasions?.includes(occasion) ? 2 : 0) + (season && i.season === season ? 1 : 0),0)}))
    .sort((a,b) => b.score-a.score || a.itemIds.join(',').localeCompare(b.itemIds.join(','))).slice(0,10);
}
function packingItems(outfits, wardrobeItems, extraIds) {
  const used = new Set([...outfits.flatMap(o=>o.itemIds), ...extraIds]);
  return wardrobeItems.filter(i=>used.has(i.id)).map(i=>({itemId:i.id,name:i.name,category:i.category,quantity:1,packed:false})).sort((a,b)=>a.category.localeCompare(b.category)||a.name.localeCompare(b.name));
}
module.exports = {fail,object,exact,string,ids,date,wardrobe,outfit,planner,packing,recommend,packingItems};
