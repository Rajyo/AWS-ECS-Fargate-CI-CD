const express = require('express');
const router = express.Router();
const app = express();
const path = require('path');


app.use(express.static('public'));
 
const options = {
    root: path.join(__dirname)
}

router.get('/', (req, res) => {
    res.sendFile('public/index.html', options);
});

router.get('/ready', (req, res) => {
    res.sendFile('public/ready.html', options);
});
 
app.use('/', router);
app.listen(8000, () => {
    console.log("Server listening on port 8000")
});