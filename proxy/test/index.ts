import { strict as assert } from 'assert';
import baretest, { Test } from 'baretest';
import fetch from 'node-fetch';

const { GITHUB_API_ENDPOINT, GITHUB_API_ENDPOINT_RELAY, HTTPBIN_ENDPOINT, HTTPBIN_ENDPOINT_RELAY } = process.env;

const test = baretest('Proxy tests');
const run = async (test: Test) => process.exit((await test.run()) ? 0 : 1);

test('query GitHub API via the actual GitHub endpoint', async function () {
    const headers = { 'content-type': 'application/json', 'user-agent': 'curl/7.58.0', host: 'api.github.com' };
    const body = null;
    const r = await fetch(GITHUB_API_ENDPOINT!, { headers, body });
    const response = await r.json();

    assert.ok(response.issue_search_url);
});

test('query GitHub API via the relayed GitHub endpoint', async function () {
    const headers = { 'content-type': 'application/json', 'user-agent': 'curl/7.58.0', host: 'api.github.com' };
    const body = null;
    const r = await fetch(GITHUB_API_ENDPOINT_RELAY!, { headers, body });
    const response = await r.json();

    assert.ok(response.issue_search_url);
});

test('DELETE httpbin.org', async function () {
    const headers = { 'content-type': 'application/json' };
    const body = JSON.stringify({ answer: '42' });
    const r = await fetch(`${HTTPBIN_ENDPOINT}/anything`, { method: 'DELETE', headers, body });
    const response = await r.json();

    assert.deepEqual(response.json.answer, '42');
});

test('DELETE httpbin.org relayed', async function () {
    const headers = { 'content-type': 'application/json', host: 'httpbin.org' };
    const body = JSON.stringify({ answer: '42' });
    const r = await fetch(`${HTTPBIN_ENDPOINT_RELAY}/anything`, { method: 'DELETE', headers, body });
    const response = await r.json();

    assert.deepEqual(response.json.answer, '42');
});

test('GET httpbin.org', async function () {
    const headers = { 'content-type': 'application/json' };
    const body = null;
    const r = await fetch(`${HTTPBIN_ENDPOINT}/anything?answer=42`, { body, headers });
    const response = await r.json();

    assert.equal(response.args.answer, '42');
});

test('GET httpbin.org relayed', async function () {
    const headers = { 'content-type': 'application/json', host: 'httpbin.org' };
    const body = null;
    const r = await fetch(`${HTTPBIN_ENDPOINT_RELAY}/anything?answer=42`, { body, headers });
    const response = await r.json();

    assert.equal(response.args.answer, '42');
});

test('PATCH httpbin.org', async function () {
    const headers = { 'content-type': 'application/json' };
    const body = JSON.stringify({ answer: '42' });
    const r = await fetch(`${HTTPBIN_ENDPOINT}/anything`, { method: 'PATCH', headers, body });
    const response = await r.json();

    assert.deepEqual(response.json.answer, '42');
});

test('PATCH httpbin.org relayed', async function () {
    const headers = { 'content-type': 'application/json', host: 'httpbin.org' };
    const body = JSON.stringify({ answer: '42' });
    const r = await fetch(`${HTTPBIN_ENDPOINT_RELAY}/anything`, { method: 'PATCH', headers, body });
    const response = await r.json();

    assert.deepEqual(response.json.answer, '42');
});

test('POST httpbin.org', async function () {
    const headers = { 'content-type': 'application/json' };
    const body = JSON.stringify({ answer: '42' });
    const r = await fetch(`${HTTPBIN_ENDPOINT}/anything`, { method: 'POST', headers, body });
    const response = await r.json();

    assert.deepEqual(response.json.answer, '42');
});

test('POST httpbin.org relayed', async function () {
    const headers = { 'content-type': 'application/json', host: 'httpbin.org' };
    const body = JSON.stringify({ answer: '42' });
    const r = await fetch(`${HTTPBIN_ENDPOINT_RELAY}/anything`, { method: 'POST', headers, body });
    const response = await r.json();

    assert.deepEqual(response.json.answer, '42');
});

test('PUT httpbin.org', async function () {
    const headers = { 'content-type': 'application/json' };
    const body = JSON.stringify({ answer: '42' });
    const r = await fetch(`${HTTPBIN_ENDPOINT}/anything`, { method: 'PUT', headers, body });
    const response = await r.json();

    assert.deepEqual(response.json.answer, '42');
});

test('PUT httpbin.org relayed', async function () {
    const headers = { 'content-type': 'application/json', host: 'httpbin.org' };
    const body = JSON.stringify({ answer: '42' });
    const r = await fetch(`${HTTPBIN_ENDPOINT_RELAY}/anything`, { method: 'PUT', headers, body });
    const response = await r.json();

    assert.deepEqual(response.json.answer, '42');
});

await run(test);
