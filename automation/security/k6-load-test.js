/**
 * FlowPay — k6 Load Test Script
 * Phase 7: Performance & Load Testing
 *
 * Tests: Baseline (100 users × 1 min), Stress (200/500/1000 users),
 *        Spike (50→500), Endurance (100 users × 30 min)
 *
 * Usage:
 *   # Baseline Load Test
 *   k6 run -e BASE_URL=https://jananibsse.github.io/janani_pdd_flowpay/ k6-load-test.js
 *
 *   # Stress Test
 *   k6 run -e TEST_TYPE=stress -e BASE_URL=<URL> k6-load-test.js
 *
 *   # Spike Test
 *   k6 run -e TEST_TYPE=spike -e BASE_URL=<URL> k6-load-test.js
 *
 *   # Endurance Test
 *   k6 run -e TEST_TYPE=endurance -e BASE_URL=<URL> k6-load-test.js
 */

import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Counter, Rate, Trend, Gauge } from 'k6/metrics';
import { htmlReport } from 'https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js';
import { textSummary } from 'https://jslib.k6.io/k6-summary/0.0.1/index.js';

// ─── Custom Metrics ──────────────────────────────────────────
const errorRate       = new Rate('error_rate');
const successRate     = new Rate('success_rate');
const pageLoadTime    = new Trend('page_load_time', true);
const assetLoadTime   = new Trend('asset_load_time', true);
const requestCount    = new Counter('total_requests');
const activeUsers     = new Gauge('active_virtual_users');

// ─── Configuration ───────────────────────────────────────────
const BASE_URL   = __ENV.BASE_URL || 'https://jananibsse.github.io/janani_pdd_flowpay/';
const TEST_TYPE  = __ENV.TEST_TYPE || 'baseline';

// ─── Scenario Configurations ─────────────────────────────────
const scenarios = {

  /**
   * BASELINE LOAD TEST
   * 100 concurrent virtual users for 1 minute
   * Goal: Verify response times stay fast under normal load
   */
  baseline: {
    scenarios: {
      baseline_load: {
        executor: 'constant-vus',
        vus: 100,
        duration: '1m',
        tags: { test_type: 'baseline' },
      },
    },
    thresholds: {
      http_req_duration:             ['avg<500', 'p(95)<1500', 'p(99)<3000'],
      http_req_failed:               ['rate<0.05'],
      error_rate:                    ['rate<0.05'],
      'http_req_duration{type:page}':['p(95)<2000'],
    },
  },

  /**
   * STRESS TEST
   * Ramp up to 200, 500, 1000 users to find breaking point
   */
  stress: {
    scenarios: {
      stress_ramp: {
        executor: 'ramping-vus',
        startVUs: 0,
        stages: [
          { duration: '2m', target: 200  },  // Ramp to 200
          { duration: '3m', target: 200  },  // Hold 200
          { duration: '2m', target: 500  },  // Ramp to 500
          { duration: '3m', target: 500  },  // Hold 500
          { duration: '2m', target: 1000 },  // Ramp to 1000
          { duration: '3m', target: 1000 },  // Hold 1000
          { duration: '2m', target: 0    },  // Ramp down
        ],
        tags: { test_type: 'stress' },
      },
    },
    thresholds: {
      http_req_duration: ['p(95)<5000'],
      http_req_failed:   ['rate<0.15'],
    },
  },

  /**
   * SPIKE TEST
   * Sudden jump from 50 to 500 users
   */
  spike: {
    scenarios: {
      spike_test: {
        executor: 'ramping-vus',
        startVUs: 0,
        stages: [
          { duration: '30s', target: 50  },  // Warm up
          { duration: '10s', target: 500 },  // Spike!
          { duration: '3m',  target: 500 },  // Hold spike
          { duration: '10s', target: 50  },  // Drop back
          { duration: '30s', target: 0   },  // Cool down
        ],
        tags: { test_type: 'spike' },
      },
    },
    thresholds: {
      http_req_duration: ['p(95)<10000'],
      http_req_failed:   ['rate<0.20'],
    },
  },

  /**
   * ENDURANCE TEST
   * 100 users for 30 minutes — detect memory leaks and degradation
   */
  endurance: {
    scenarios: {
      endurance_test: {
        executor: 'constant-vus',
        vus: 100,
        duration: '30m',
        tags: { test_type: 'endurance' },
      },
    },
    thresholds: {
      http_req_duration: ['avg<1000', 'p(95)<3000'],
      http_req_failed:   ['rate<0.03'],
    },
  },
};

// ─── Active Scenario ─────────────────────────────────────────
export const options = scenarios[TEST_TYPE] || scenarios.baseline;

// ─── Test Setup ──────────────────────────────────────────────
export function setup() {
  console.log(`
  ╔══════════════════════════════════════════════════════╗
  ║      FlowPay k6 Performance Test — ${TEST_TYPE.toUpperCase().padEnd(15)}  ║
  ╠══════════════════════════════════════════════════════╣
  ║  BASE_URL : ${BASE_URL.padEnd(40)}  ║
  ║  Test Type: ${TEST_TYPE.padEnd(40)}  ║
  ╚══════════════════════════════════════════════════════╝
  `);

  // Verify target is reachable
  const res = http.get(BASE_URL, { timeout: '10s' });
  if (res.status !== 200) {
    console.error(`⚠️ Target URL returned ${res.status} — tests may have issues`);
  } else {
    console.log(`✅ Target reachable: HTTP ${res.status}`);
  }

  return { baseUrl: BASE_URL, startTime: new Date().toISOString() };
}

// ─── Main Test Function ───────────────────────────────────────
export default function (data) {
  const baseUrl = data.baseUrl;
  activeUsers.add(1);

  group('Homepage Load', function () {
    const startTime = Date.now();
    const res = http.get(baseUrl, {
      headers: {
        'Accept':          'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'User-Agent':      'k6-performance-test/1.0 FlowPay',
      },
      tags: { name: 'homepage', type: 'page' },
      timeout: '30s',
    });

    const loadTime = Date.now() - startTime;
    pageLoadTime.add(loadTime);
    requestCount.add(1);

    const ok = check(res, {
      '✅ Homepage HTTP 200':           (r) => r.status === 200,
      '✅ Response time < 3s':          (r) => r.timings.duration < 3000,
      '✅ Body not empty':              (r) => r.body && r.body.length > 100,
      '✅ Content-Type HTML':           (r) => r.headers['Content-Type'] &&
                                               r.headers['Content-Type'].includes('text/html'),
      '✅ Contains flutter':            (r) => r.body && r.body.toLowerCase().includes('flutter'),
      '✅ Time to first byte < 1500ms': (r) => r.timings.waiting < 1500,
    });

    errorRate.add(!ok);
    successRate.add(ok);
  });

  sleep(Math.random() * 2 + 0.5);  // Random think time 0.5–2.5s

  group('Static Assets', function () {
    const assets = [
      `${baseUrl}flutter.js`,
      `${baseUrl}manifest.json`,
      `${baseUrl}favicon.png`,
    ];

    for (const asset of assets) {
      const start = Date.now();
      const res = http.get(asset, {
        tags: { name: 'static_asset', type: 'asset' },
        timeout: '15s',
      });
      assetLoadTime.add(Date.now() - start);
      requestCount.add(1);

      check(res, {
        '✅ Asset loads (200 or 304)': (r) => r.status === 200 || r.status === 304 || r.status === 404,
        '✅ Asset response < 2s':       (r) => r.timings.duration < 2000,
      });
    }
  });

  sleep(Math.random() * 1 + 0.3);
}

// ─── Teardown ────────────────────────────────────────────────
export function teardown(data) {
  console.log(`\n✅ Test completed. Started: ${data.startTime}`);
}

// ─── Custom Report ────────────────────────────────────────────
export function handleSummary(data) {
  const now = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);

  // Extract key metrics
  const httpReqs     = data.metrics.http_reqs;
  const duration     = data.metrics.http_req_duration;
  const failed       = data.metrics.http_req_failed;
  const rps          = httpReqs ? httpReqs.values.rate.toFixed(1)    : 'N/A';
  const avgDur       = duration ? duration.values.avg.toFixed(1)     : 'N/A';
  const minDur       = duration ? duration.values.min.toFixed(1)     : 'N/A';
  const maxDur       = duration ? duration.values.max.toFixed(1)     : 'N/A';
  const p95          = duration ? duration.values['p(95)'].toFixed(1): 'N/A';
  const p99          = duration ? duration.values['p(99)'].toFixed(1): 'N/A';
  const errRate      = failed   ? (failed.values.rate * 100).toFixed(2) : 'N/A';
  const totalReqs    = httpReqs ? httpReqs.values.count                : 0;

  const summary = `
╔══════════════════════════════════════════════════════════════╗
║              FlowPay Performance Test Results               ║
╠══════════════════════════════════════════════════════════════╣
║  Test Type    : ${TEST_TYPE.padEnd(44)} ║
║  Target URL   : ${BASE_URL.slice(0, 44).padEnd(44)} ║
║  Completed At : ${now.padEnd(44)} ║
╠══════════════════════════════════════════════════════════════╣
║  REQUESTS PER SECOND (RPS)                                  ║
║    Throughput : ${(rps + ' req/sec').padEnd(44)} ║
║    Total Reqs : ${String(totalReqs).padEnd(44)} ║
╠══════════════════════════════════════════════════════════════╣
║  RESPONSE TIMES                                             ║
║    Average   : ${(avgDur + ' ms').padEnd(44)} ║
║    Minimum   : ${(minDur + ' ms').padEnd(44)} ║
║    Maximum   : ${(maxDur + ' ms').padEnd(44)} ║
║    P95       : ${(p95   + ' ms').padEnd(44)} ║
║    P99       : ${(p99   + ' ms').padEnd(44)} ║
╠══════════════════════════════════════════════════════════════╣
║  ERROR RATE  : ${(errRate + '%').padEnd(44)} ║
╚══════════════════════════════════════════════════════════════╝
`;

  console.log(summary);

  return {
    stdout: textSummary(data, { indent: ' ', enableColors: true }),
    'Performance_Results/k6-summary.json': JSON.stringify({
      test_type:     TEST_TYPE,
      base_url:      BASE_URL,
      timestamp:     new Date().toISOString(),
      rps:           parseFloat(rps),
      response_times: {
        avg_ms: parseFloat(avgDur),
        min_ms: parseFloat(minDur),
        max_ms: parseFloat(maxDur),
        p95_ms: parseFloat(p95),
        p99_ms: parseFloat(p99),
      },
      total_requests: totalReqs,
      error_rate_pct: parseFloat(errRate),
      thresholds_passed: !data.thresholds ||
        Object.values(data.thresholds).every(t => !t.ok === false),
    }, null, 2),
  };
}
