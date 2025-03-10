#!/bin/bash

BUILD_DIR=build-ut
HTML_DIR=html
REPORT_DIR=report

# 工程列表
targets=()
targets[${#targets[*]}]=dde-bluetooth-dialog
targets[${#targets[*]}]=dde-full-filesystem
targets[${#targets[*]}]=dde-license-dialog
targets[${#targets[*]}]=dde-lowpower
targets[${#targets[*]}]=dde-notification-plugin
targets[${#targets[*]}]=dde-osd
targets[${#targets[*]}]=dde-suspend-dialog
targets[${#targets[*]}]=dde-warning-dialog
targets[${#targets[*]}]=dde-welcome
targets[${#targets[*]}]=dde-wm-chooser
targets[${#targets[*]}]=dmemory-warning-dialog
targets[${#targets[*]}]=dnetwork-secret-dialog
targets[${#targets[*]}]=dde-touchscreen-dialog

# 编译源文件
cd ../
rm -rf $BUILD_DIR
mkdir $BUILD_DIR
cd $BUILD_DIR || return

cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j 8

for target in ${targets[*]}; do
    # 生成单元测试报告
    ./ut-${target} --gtest_output=xml:./$REPORT_DIR/ut-report_${target}.xml
    mv asan_${target}.log* asan_${target}.log
done

# 单元测试覆盖率
lcov --directory . --capture --output-file ./coverage.info
lcov --remove ./coverage.info "*/tests/*" "*/usr/include*" "*build/src*" "*persistence.cpp*" "*notifications_dbus_adaptor.cpp*" "*notifysettings.cpp*" "*dbuslogin1manager.cpp*" "*persistence.h*" "*notifysettings.h*" "*dbuslogin1manager.h*" "*dbusdockinterface.h*" "*dbus_daemon_interface.h*" "*dbus_daemon_interface.cpp*" "*/global_util/dbus/*" "*/global_util/xkbparser*" "*icondata.h*" "*icondata.cpp*" "*kblayoutindicator.h*" "*kblayoutindicator.cpp*" -o ./coverage.info

# 生成html
genhtml -o ./$HTML_DIR ./coverage.info

mv ./$HTML_DIR/index.html $HTML_DIR/cov_dde-session-ui.html