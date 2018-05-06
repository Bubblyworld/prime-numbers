/*
  This package is a simple test of prometheus and grafana, open source tools
  for respectively instrumenting and dashboarding services. We run a service
  that launches three threads, each of which attempts to determine whether
  successive integers are prime using trial division. To avoid killing the
  server, the threads sleep after every 1000 trial attempts for some preset
  duration.

  We use prometheus/grafana to monitor the time each thread takes to test
  each integer for primality.
*/
package main

import (
	"fmt"
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"guypj/instrumenting/prime"
)

func registerMetrics() {
	prometheus.MustRegister(prime.IntegersTested)
}

func startThreads() {
	for i := 0; i < 3; i++ {
		threadLabel := fmt.Sprintf("thread_%d", i)
		sleepFor := time.Millisecond * time.Duration(i*50)

		go prime.TestPrimalityForever(sleepFor, threadLabel)
	}
}

func main() {
	registerMetrics()

	http.Handle("/metrics", promhttp.Handler())
	http.ListenAndServe("localhost:8080", nil)
}
