#!/bin/bash

set -e

# https://stackoverflow.com/a/246128
ScriptDir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

input=${ScriptDir}/../Packages/tests/Compilation/input.txt
define=${ScriptDir}/../Packages/tests/Compilation/define.txt

rm -rf ${input} ${define}

echo MIES_Include                  >> ${input}
echo UTF_Basic                     >> ${input}
echo UTF_PAPlot                    >> ${input}
echo UTF_HardwareAnalysisFunctions >> ${input}
echo UTF_HardwareBasic             >> ${input}

echo DEBUGGING_ENABLED         >> ${define}
echo EVIL_KITTEN_EATING_MODE   >> ${define}
echo BACKGROUND_TASK_DEBUGGING >> ${define}
echo THREADING_DISABLED        >> ${define}
echo SWEEPFORMULA_DEBUG        >> ${define}

${ScriptDir}/autorun-test.sh $@

exit 0