const { v4: uuid } = require('uuid');


/**
 * HTTP Cloud Function.
 * This function is exported by index.js, and is executed when
 * you make an HTTP request to the deployed function's endpoint.
 *
 * @param {Object} req Cloud Function request context.
 *                     More info: https://expressjs.com/en/api.html#req
 * @param {Object} res Cloud Function response context.
 *                     More info: https://expressjs.com/en/api.html#res
 */
exports.main = (req, res) => {
    const id = uuid()
    console.log(`[ID: "${id}"][Auth: ${req.query.key}] Processing a ${req.method} request.`)
    res.status(201).json({
        id: id,
        time: new Date(),
        query: req.query,
        body: req.body
    })
};