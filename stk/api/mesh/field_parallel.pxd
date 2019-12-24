# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp.vector cimport vector
from .stk_mesh_fwd cimport *
from .bulk cimport BulkData
from .field cimport FieldBase

ctypedef FieldBase* FieldBasePtr_
ctypedef vector[const FieldBase*] FieldBaseVector_

cdef extern from "stk_mesh/base/FieldParallel.hpp" namespace "stk::mesh" nogil:
    void communicate_field_data(const Ghosting& ghosts, const FieldBaseVector_& fields)

    void copy_owned_to_shared(const BulkData& mesh, const FieldBaseVector_& fields)

    void parallel_sum(const BulkData& mesh, const FieldBaseVector_& fields)
    void parallel_max(const BulkData& mesh, const FieldBaseVector_& fields)
    void parallel_min(const BulkData& mesh, const FieldBaseVector_& fields)

    void parallel_sum_including_ghosts(const BulkData& mesh, const FieldBaseVector_& fields)
    void parallel_max_including_ghosts(const BulkData& mesh, const FieldBaseVector_& fields)
    void parallel_min_including_ghosts(const BulkData& mesh, const FieldBaseVector_& fields)
