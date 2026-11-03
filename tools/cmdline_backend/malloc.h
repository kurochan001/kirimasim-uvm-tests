// The pinned regex translation uses standard malloc/free declarations.
// Provide the portable standard header on hosts without a malloc.h header.
#ifndef KIRIMASIM_CMDLINE_MALLOC_COMPAT_H
#define KIRIMASIM_CMDLINE_MALLOC_COMPAT_H
#include <stdlib.h>
#endif
