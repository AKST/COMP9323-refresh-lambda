import 'babel-polyfill';
import { Client } from 'pg';

export async function handler (event, context, cb) {
    const client = new Client({
        user: process.env.DB_USER,
        host: process.env.DB_HOST,
        database: process.env.DB_DATABASE,
        password: process.env.DB_PASSWORD,
        port: 5432,
    });

    try {
        await client.connect();
        await client.query('REFRESH MATERIALIZED VIEW todays_bookings');
        await client.end();
        cb(null, 'bingo');
    }
    catch (e) {
        cb(e);
    }
}
