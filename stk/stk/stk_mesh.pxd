# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from ..api.util.parallel cimport Parallel
from ..api.mesh.meta cimport StkMetaData
from ..api.mesh.bulk cimport StkBulkData
from ..api.io.io cimport StkIoBroker

cdef class StkMesh:
    cdef readonly Parallel comm
    cdef readonly StkMetaData meta
    cdef readonly StkBulkData bulk
    cdef readonly StkIoBroker stkio
