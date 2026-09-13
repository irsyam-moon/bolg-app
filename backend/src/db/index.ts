import mysql from 'mysql2/promise'; 
const connection = await mysql.createConnection({ 
host: 'localhost', 
user: 'root', 
database: 'db_blog_app', 
// tambahin kalau perlu! Kalau gk ya gk usah.. password: “password pembaca” 
}); 
export default connection;