const mongoUser = process.env.NOTEBOOKS_DB_USER;
const mongoPassword = process.env.NOTEBOOKS_DB_PASSWORD;
const mongoDb = process.env.NOTEBOOKS_DB_NAME;

console.log("Initializing Notebooks DB user")

db = db.getSiblingDB(mongoDb);

db.createUser(
    {
        user: mongoUser,
        pwd: mongoPassword,
        roles: [
            {
                role: "readWrite",
                db: mongoDb
            }
        ]
    }
)