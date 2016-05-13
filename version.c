/**
 * @file   version.c
 * @author Callum Prentice (via Nat Goodspeed)
 * @date   2016-05-12
 * @brief  Report library version number.
 *         For a library whose version number is tracked in a C or C++ header
 *         file, it's more robust to build a helper program to report it than
 *         to manually parse the header file. The library might change the
 *         syntax with which it defines the version number, but we can assume
 *         it will remain valid C / C++.
 * 
 * $LicenseInfo:firstyear=2014&license=internal$
 * Copyright (c) 2014, Linden Research, Inc.
 * $/LicenseInfo$
 */

#include VERSION_HEADER_FILE
#include <stdio.h>

int main(int argc, char *argv[])
{
    printf("%d.%d.%d.%s\n", VERSION_MAJOR_MACRO, VERSION_MINOR_MACRO, VERSION_REVISION_MACRO, VERSION_BUILD_MACRO);
    return 0;
}
