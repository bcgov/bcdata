## CRAN check issues

* Fixed an issue where failures in examples that called a web resource would cause a check failure
(https://www.stats.ox.ac.uk/pub/bdr/donttest/bcdata.out). Now all examples that call a web resource are 
wrapped in try() so if the examples fail they will not trigger a check error.

## Test environments
* local macOS install (macOS Mojave 10.14.6), R 4.0.2
* local Windows 10 install, R 4.0.3
* ubuntu 18.04 (on github actions), R 4.0.3, 3.6.3, R 3.5
* ubuntu 18.04 (on github actions), R-devel (2020-10-20 r79356)
* Windows Server 2019 (on github actions), R 4.0.3
* macOS Catalina 10.15 (on github actions), R 4.0.3
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 note

