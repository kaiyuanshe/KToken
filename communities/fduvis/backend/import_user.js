const createConnectionPool = require('@databases/pg');
const {sql} = require('@databases/pg');
const axios = require('axios').default;
require('dotenv').config();

async function create_table() {
        const db = createConnectionPool('postgres://' + process.env.PG_ENDPOINT + '@localhost:5432');
        await db.query(sql.file('./yq_actions.sql'));
        await db.query(sql.file('./yq_users.sql'));
        await db.dispose();
}

async function write_user() {
        const db = createConnectionPool('postgres://' + process.env.PG_ENDPOINT + '@localhost:5432');
        let user_id = "22870365";
        let account = "0xD81A0cECB753cc55F3fe87f4960DAB01e50df727";
        var name;
        var login;
        try {
                const endpoint = "https://fduvis.yuque.com/api/v2/users/" + user_id;
                const auth = {
                        headers: {
                                "X-Auth-Token": process.env.YUQUE_TOKEN,
                        }
                };
                const response = await axios.get(endpoint, auth);
                name = response.data.data.name;
                login = response.data.data.login;
        } catch (error) {
                console.log("Fetching User ID Failed");
                console.log(error);
        }

        await db.query(sql`
                insert into yq_users(user_name, user_id, user_login, user_wallet)
                values (${name}, ${user_id}, ${login}, ${account})
        `);
        await db.dispose();
}

write_user().catch( (err) => {
        console.error(err);
        process.exit(1);
})
