use world;
db.createCollection("countries");
show databases;
show collections;
db.countries.insertOne({
	name: "Ukraine",
	rating: 85
});
db.countries.insertMany([
	{name: "Belgium", rating: 83},
	{name: "Germany", rating: 46},
	{name: "Canada", rating: 2}
]);
db.countries.find();