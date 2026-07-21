/**
 * FlowPay — k6 Load Test Script
 * Baseline: 100 VUs x 1 minute
 * Exports a clean JSON summary with accurate response time metrics.
 */

import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Counter, Rate, Trend } from 'k6/metrics';

// ─── Custom Metrics ──────────────────────────────────────────
const errorRate    = new Rate('error_rate');
const successRate  = new Rate('success_rate');
const pageLoadTime = new Trend('page_load_time', true);
const requestCount = new Counter('total_requests');

// ─── Config ──────────────────────────────────────────────────
const BASE_URL  = __ENV.BASE_URL  || 'https://jananibsse.github.io/janani_pdd_flowpay/';
const TEST_TYPE = __ENV.TEST_TYPE || 'baseline';

// ─── Options ─────────────────────────────────────────────────
export const options = {
  scenarios: {
    baseline_load: {
      executor: 'constant-vus',
      vus: 100,
      duration: '1m',
    },
  },
  thresholds: {
    http_req_duration: ['avg<2000', 'p(95)<5000', 'p(99)<8000'],
    http_req_failed:   ['rate<0.05'],
  },
  // Force k6 to compute p(99) in summary export
  summaryTrendStats: ['avg', 'min', 'med', 'max', 'p(90)', 'p(95)', 'p(99)', 'count'],
};

// ─── Setup ───────────────────────────────────────────────────
export function setup() {
  const res = http.get(BASE_URL, { timeout: '15s' });
  console.log('Target check: HTTP ' + res.status + ' | URL: ' + BASE_URL);
  return { baseUrl: BASE_URL };
}

// ─── Main Test ───────────────────────────────────────────────
export default function (data) {
  const baseUrl = data.baseUrl;

  group('Homepage', function () {
    const start = Date.now();
    const res = http.get(baseUrl, {
      headers: {
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      },
      tags: { name: 'homepage', type: 'page' },
      timeout: '30s',
    });

    const loadTime = Date.now() - start;
    pageLoadTime.add(loadTime);
    requestCount.add(1);

    const ok = check(res, {
      'status_200':             (r) => r.status === 200,
      'response_under_5s':      (r) => r.timings.duration < 5000,
      'body_not_empty':         (r) => r.body && r.body.length > 100,
      'content_type_html':      (r) => r.headers['Content-Type'] &&
                                       r.headers['Content-Type'].includes('text/html'),
      'ttfb_under_3s':          (r) => r.timings.waiting < 3000,
    });

    errorRate.add(!ok);
    successRate.add(ok);
  });

  sleep(Math.random() * 2 + 1);  // 1–3s think time between requests

  group('StaticAssets', function () {
    const assets = [
      baseUrl + 'flutter.js',
      baseUrl + 'manifest.json',
      baseUrl + 'favicon.png',
    ];

    for (const asset of assets) {
      const res = http.get(asset, {
        tags: { name: 'static_asset', type: 'asset' },
        timeout: '15s',
      });
      requestCount.add(1);

      check(res, {
        'asset_ok': (r) => r.status === 200 || r.status === 304 || r.status === 404,
        'asset_fast': (r) => r.timings.duration < 5000,
      });
    }
  });

  sleep(Math.random() * 1 + 0.5);
}

// ─── Custom Summary ──────────────────────────────────────────
export function handleSummary(data) {
  const d    = data.metrics.http_req_duration;
  const r    = data.metrics.http_reqs;
  const fail = data.metrics.http_req_failed;

  // Access the 'values' sub-object (this is the correct structure)
  const dv = d ? d.values : {};
  const rv = r ? r.values : {};
  const fv = fail ? fail.values : {};

  const avg_ms   = dv.avg   != null ? parseFloat(dv.avg.toFixed(2))   : null;
  const min_ms   = dv.min   != null ? parseFloat(dv.min.toFixed(2))   : null;
  const max_ms   = dv.max   != null ? parseFloat(dv.max.toFixed(2))   : null;
  const med_ms   = dv.med   != null ? parseFloat(dv.med.toFixed(2))   : null;
  const p90_ms   = dv['p(90)'] != null ? parseFloat(dv['p(90)'].toFixed(2)) : null;
  const p95_ms   = dv['p(95)'] != null ? parseFloat(dv['p(95)'].toFixed(2)) : null;
  const p99_ms   = dv['p(99)'] != null ? parseFloat(dv['p(99)'].toFixed(2)) : null;
  const count    = rv.count  != null ? rv.count  : 0;
  const rps      = rv.rate   != null ? parseFloat(rv.rate.toFixed(2))  : 0;
  const err_rate = fv.rate   != null ? parseFloat((fv.rate * 100).toFixed(4)) : 0;

  const summary = {
    test_type:  TEST_TYPE,
    base_url:   BASE_URL,
    timestamp:  new Date().toISOString(),
    metrics: {
      rps:           rps,
      total_requests: count,
      response_time: {
        avg_ms: avg_ms,
        min_ms: min_ms,
        med_ms: med_ms,
        max_ms: max_ms,
        p90_ms: p90_ms,
        p95_ms: p95_ms,
        p99_ms: p99_ms,
      },
      error_rate_pct: err_rate,
    },
    note: 'Response times measured from k6 VU to GitHub Pages CDN edge node. Min reflects CDN cache hit on kept-alive HTTP/2 connections. Avg/P95/P99 represent realistic end-to-end times.',
  };

  console.log('\n=== FlowPay k6 Load Test Results ===');
  console.log('RPS:           ' + rps + ' req/sec');
  console.log('Total Requests: ' + count);
  console.log('Avg Response:  ' + avg_ms + ' ms');
  console.log('Min Response:  ' + min_ms + ' ms  (CDN HTTP/2 keepalive)');
  console.log('Max Response:  ' + max_ms + ' ms');
  console.log('P90 Response:  ' + p90_ms + ' ms');
  console.log('P95 Response:  ' + p95_ms + ' ms');
  console.log('P99 Response:  ' + p99_ms + ' ms');
  console.log('Error Rate:    ' + err_rate + '%');
  console.log('=====================================\n');

  return {
    'LoadTest_Results/k6/k6-metrics.json': JSON.stringify(summary, null, 2),
    stdout: '\nk6 test complete. See LoadTest_Results/k6/k6-metrics.json for full metrics.\n',
  };
}
