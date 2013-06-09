#!/usr/bin/env python
# -*- coding: utf-8 -*-

# usage: python run-tests.py [ruby]

import os
import sys
import shutil

tests = {}
tests['ruby'] = {'syntax_file': '$VIMRUNTIME/syntax/ruby.vim', 'file':  'languages/ruby/test-file1.rb', 'extra_setup_lines' : [] }
tests['vim'] =  {'syntax_file': '$VIMRUNTIME/syntax/vim.vim', 'file':  '$VIMRUNTIME/autoload/rubycomplete.vim', 'extra_setup_lines' : [] }

for k in tests:
    tests[k]['name'] = k

extra_setup_lines_file = "/tmp/extra_setup_lines"
outfile = "/tmp/outfile"

def s(s):
    return "\"%s\"" %s

def run_test(test, f):
    global extra_setup_lines_file
    global outfile

    if 'extra_setup_lines' in test:
        extra_setup_lines = test['extra_setup_lines']
    else:
        extra_setup_lines = []
        
    fx = open(extra_setup_lines_file, "w")
    fx.write("\n".join(test['extra_setup_lines']))
    fx.close()

    results = {}
    for engine in range(1,3):
        report_file = "syntime-%s-%s.txt" % (test['name'], engine)
        cmd = "vim -u NONE -U NONE -N -g --nofork -c 'source test.vim' -c 'call AutomaticTest(%d, %s, %s, %s, %s, %s)' -c 'quit!'" % (engine, s(extra_setup_lines_file), s(test['file']), s(test['syntax_file']), s(outfile), s(report_file) )
        print "running cmd: %s" % cmd
        os.system(cmd)
        result = open(outfile,"r").readlines()[0].strip()
        results[engine] = result
        f.write("%s %d %s\n" % (test['name'], engine, result))

    print results
    f.write("improvement: %f \n" % (100 * (float(results[1]) - float(results[2])) / float(results[1])))

def main():
    global tests

    f = open("results","w")

    if len(sys.argv) > 1:
        test_names = sys.argv[1:]
    else:
        test_names = tests.keys()

    for t in test_names:
        run_test(tests[t],f)

    f.flush()
    f.close()

    print "results: >>>"
    for l in open("results", "r").readlines():
        print l

if __name__ == "__main__":
    main()
