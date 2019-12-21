# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from .stk_mesh_fwd cimport *

cdef extern from "stk_mesh/base/CreateEdges.hpp" namespace "stk::mesh":
    void create_edges(BulkData& bulk)
    void create_edges(BulkData& bulk, const Selector& sel)
    void create_edges(BulkData& bulk, const Selector& sel, Part* new_part)
