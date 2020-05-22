const { strict: assert } = require('assert');
const bent = require('bent');

const { GITHUB_API_ENDPOINT, GITHUB_API_ENDPOINT_RELAY, HTTPBIN_ENDPOINT, HTTPBIN_ENDPOINT_RELAY } = process.env;

test('query GitHub API via the actual GitHub endpoint', async function () {
    const headers = { 'user-agent': 'curl/7.58.0', host: 'api.github.com' };
    const body = null;
    const request = bent('json');
    const response = await request(GITHUB_API_ENDPOINT, body, headers);

    assert.ok(response.issue_search_url);
});

test('query GitHub API via the relayed GitHub endpoint', async function () {
    const headers = { 'user-agent': 'curl/7.58.0', host: 'api.github.com' };
    const body = null;
    const request = bent('json');
    const response = await request(GITHUB_API_ENDPOINT_RELAY, body, headers);

    assert.ok(response.issue_search_url);
});

test('DELETE httpbin.org', async function () {
    const headers = { };
    const body = { answer: '42' };
    const request = bent('DELETE', 'json');
    const response = await request(`${HTTPBIN_ENDPOINT}/anything`, body, headers);

    assert.deepEqual(response.json.answer, '42');
});

test('DELETE httpbin.org relayed', async function () {
    const headers = { host: 'httpbin.org' };
    const body = { answer: '42' };
    const request = bent('DELETE', 'json');
    const response = await request(`${HTTPBIN_ENDPOINT_RELAY}/anything`, body, headers);

    assert.deepEqual(response.json.answer, '42');
});

test('GET httpbin.org', async function () {
    const headers = { };
    const body = null;
    const request = bent('json');
    const response = await request(`${HTTPBIN_ENDPOINT}/anything?answer=42`, body, headers);

    assert.equal(response.args.answer, '42');
});

test('GET httpbin.org relayed', async function () {
    const headers = { host: 'httpbin.org' };
    const body = null;
    const request = bent('json');
    const response = await request(`${HTTPBIN_ENDPOINT_RELAY}/anything?answer=42`, body, headers);

    assert.equal(response.args.answer, '42');
});

test('PATCH httpbin.org', async function () {
    const headers = { };
    const body = { answer: '42' };
    const request = bent('PATCH', 'json');
    const response = await request(`${HTTPBIN_ENDPOINT}/anything`, body, headers);

    assert.deepEqual(response.json.answer, '42');
});

test('PATCH httpbin.org relayed', async function () {
    const headers = { host: 'httpbin.org' };
    const body = { answer: '42' };
    const request = bent('PATCH', 'json');
    const response = await request(`${HTTPBIN_ENDPOINT_RELAY}/anything`, body, headers);

    assert.deepEqual(response.json.answer, '42');
});

test('POST httpbin.org', async function () {
    const headers = { };
    const body = { answer: '42' };
    const request = bent('POST', 'json');
    const response = await request(`${HTTPBIN_ENDPOINT}/anything`, body, headers);

    assert.deepEqual(response.json.answer, '42');
});

test('POST httpbin.org relayed', async function () {
    const headers = { host: 'httpbin.org' };
    const body = { answer: '42' };
    const request = bent('POST', 'json');
    const response = await request(`${HTTPBIN_ENDPOINT_RELAY}/anything`, body, headers);

    assert.deepEqual(response.json.answer, '42');
});

test('PUT httpbin.org', async function () {
    const headers = { };
    const body = { answer: '42' };
    const request = bent('PUT', 'json');
    const response = await request(`${HTTPBIN_ENDPOINT}/anything`, body, headers);

    assert.deepEqual(response.json.answer, '42');
});

test('PUT httpbin.org relayed', async function () {
    const headers = { host: 'httpbin.org' };
    const body = { answer: '42' };
    const request = bent('PUT', 'json');
    const response = await request(`${HTTPBIN_ENDPOINT_RELAY}/anything`, body, headers);

    assert.deepEqual(response.json.answer, '42');
});
