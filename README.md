# PittUoHMOOC. University of Pittsburgh and University of Helsinki Java MOOC Data Analysis

Peter Brusilovsky, Ph.D. ([peterb.pitt.edu](mailto:peterb.pitt.edu)), [http://brusilovsky.org](http://brusilovsky.org)

Michael Yudelson, Ph.D. ([yudelson@andrew.cmu.edu](mailto:yudelson@andrew.cmu.edu),[michael.yudelson@act.org](mailto:michael.yudelson@act.org)), [http://yudelson.info](http://yudelson.info)

Roya Hosseini, ABD ([roh38@pitt.edu](mailto:roh38@pitt.edu))

We are performing a set of Big Data analyses to study student learning in a Programming MOOC (Java). The data is collected at the University of Helsinki and is comprised of student work on class problems in a modified IDE.

We are focusing on student behaviors and learning. Behaviors are patterns of student editing the code of the problem solutions. We are utilizing automatically parsed programming constructs to model student learning. The overarching goal is to use traces of behavior and learning to build assistive technology to help students learn more efficiently.

# Java Course and Java MOOC

General words





# Appendix A. Key Web Locations, Files, and Directory Structure

Key locations.

* `https://github.com/PAWSLabUniversityOfPittsburgh/pittuohmooc` - code repository
* `https://www.researchgate.net/project/Automated-Student-Behavior-Modeling-In-a-Programming-MOOC` – ResearchGate project

Files and Directory Structure.

* `make_nov_2017.sh` – the over-arching make file;
* `./code/` - code and scripts;
* `./data/` - source and derived data;
* `./bin/` - compiled code and libraries;
* `./model/` - fit models;
* `./predict/` - model predictions;
* `./result/` - results, including graphics;
* `./paper/` - publication files;
* `rsync-excludes.txt` - list of files excluded from `rsync`.
* `format.txt` - specification of the data formats.

All folders, but `./code/` are excluded from the git repository. All folders but `./code/` are included into data sync via `rsync`
