'use strict';
const {test}=require('node:test');
const assert=require('node:assert/strict');
const L=require('../src/logic');

test('rejects invalid dates and fields',()=>{
  assert.throws(()=>L.date('2026-02-30'),/Invalid date/);
  assert.throws(()=>L.wardrobe({name:'Shirt',category:'top',uid:'someone-else'}),/Unknown field/);
  assert.throws(()=>L.outfit({name:'Look',itemIds:['a','a']}),/Duplicate itemIds/);
  assert.throws(()=>L.packing({name:'Trip',startDate:'2026-10-02',endDate:'2026-10-01',outfitIds:['a']}),/endDate/);
});
test('recommendations honor occasion and season and ignore archived items',()=>{
  const items=[
    {id:'a',name:'Shirt',category:'top',season:'summer',occasions:['casual']},
    {id:'b',name:'Pants',category:'bottom',season:'all',occasions:[]},
    {id:'c',name:'Shoes',category:'shoes',season:'all',occasions:['casual']},
    {id:'d',name:'Dress',category:'dress',season:'winter',occasions:[]},
    {id:'e',name:'Other shoes',category:'shoes',season:'all',archived:true}
  ];
  assert.deepEqual(L.recommend(items,{season:'summer',occasion:'casual'}),[{itemIds:['a','b','c'],score:5}]);
});
test('packing merges repeated items and initializes checkboxes',()=>{
  const outfits=[{itemIds:['a','b']},{itemIds:['a']}];
  const items=[{id:'a',name:'Tee',category:'top'},{id:'b',name:'Boots',category:'shoes'}];
  assert.deepEqual(L.packingItems(outfits,items,['b']),[
    {itemId:'b',name:'Boots',category:'shoes',quantity:1,packed:false},
    {itemId:'a',name:'Tee',category:'top',quantity:1,packed:false}
  ]);
});
