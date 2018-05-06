/*
  This package contains simple code for factorising successive integers with
  trial division, sleeping every 1000 trial attempts for some preset duration.
  If an integer is discovered to be prime, it will be logged.
*/
package prime

import (
	"time"

	"github.com/prometheus/client_golang/prometheus"
)

var IntegersTested = prometheus.NewCounterVec(
	prometheus.CounterOpts{
		Name: "total_integers_tested",
		Help: "Number of integers tested for primality.",
	},
	[]string{"thread"},
)

var PrimesFound = prometheus.NewCounterVec(
	prometheus.CounterOpts{
		Name: "total_primes_found",
		Help: "Number of primes found.",
	},
	[]string{"thread"},
)

/*
  testPrimality will attempt to test `n` for primality with trial division.
  Every total 1000 iterations of a trial divison we sleep for the given duration,
  where we are given the current iteration count as the `iteration` parameter.

  It is assumed that `n` is positive and greater than 1.
*/
func testPrimality(n, iteration int64, sleepFor time.Duration) (bool, int64) {
	for i := int64(2); i < n; i++ {
		isComposite := n%i == 0
		iteration++

		if iteration == 1000 {
			time.Sleep(sleepFor)
			iteration = 0
		}

		if isComposite {
			return false, iteration
		}
	}

	return true, iteration
}

/*
  TestPrimalityForever will attempt to test successive integers for primality
  forever, starting from 2. On each success, the IntegersTested metric is
  updated for the given thread label.
*/
func TestPrimalityForever(sleepFor time.Duration, threadLabel string) {
	n, iteration := int64(2), int64(0)
	for {
		var isPrime bool
		isPrime, iteration = testPrimality(n, iteration, sleepFor)

		if isPrime {
			PrimesFound.With(prometheus.Labels{"thread": threadLabel}).Inc()
		}

		IntegersTested.With(prometheus.Labels{"thread": threadLabel}).Inc()
		n++
	}
}
