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
	"log"
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
		sleepFor := time.Millisecond * time.Duration(i*50+50)

		go prime.TestPrimalityForever(sleepFor, threadLabel)
	}
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("<html><body>Healthy.</body><html>"))
}

func main() {
	log.Println("Registering metrics.")
	registerMetrics()

	log.Println("Starting test threads.")
	startThreads()

	log.Println("Starting server on localhost:8080")
	http.Handle("/", http.HandlerFunc(rootHandler))
	http.Handle("/metrics", promhttp.Handler())
	log.Fatal(http.ListenAndServe("0.0.0.0:8080", nil))
}
