#!/bin/bash
find -name '*.rpm' -print0 | xargs -0 cp -t ./rpm/
