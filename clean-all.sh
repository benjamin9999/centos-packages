#!/bin/bash
find -type d -name 'pkg' -exec rm -rf {} +
find -type d -name 'src' -exec rm -rf {} +
find -name '*.rpm' -exec rm {} +          

