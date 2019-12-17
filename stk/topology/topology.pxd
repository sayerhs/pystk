# -*- coding: utf-8 -*-
# distutils: language = c++

from libcpp cimport bool
from libcpp.string cimport string

cdef extern from "stk_topology/topology.hpp" namespace "stk::topology" nogil:
    cpdef enum rank_t:
        NODE_RANK
        EDGE_RANK
        FACE_RANK
        ELEM_RANK
        CONSTRAINT_RANK
        INVALID_RANK

    cpdef enum topology_t:
        INVALID_TOPOLOGY
        BEGIN_TOPOLOGY
        NODE
        LINE_2
        LINE_3
        TRI_3
        TRI_4
        TRI_6
        QUAD_4
        QUAD_8
        QUAD_9
        PARTICLE
        LINE_2_1D
        LINE_3_1D
        BEAM_2
        BEAM_3
        SHELL_LINE_2
        SHELL_LINE_3
        SPRING_2
        SPRING_3
        TRI_3_2D
        TRI_4_2D
        TRI_6_2D
        QUAD_4_2D
        QUAD_8_2D
        QUAD_9_2D
        SHELL_TRI_3
        SHELL_TRI_4
        SHELL_TRI_6
        SHELL_QUAD_4
        SHELL_QUAD_8
        SHELL_QUAD_9
        TET_4
        TET_8
        TET_10
        TET_11
        PYRAMID_5
        PYRAMID_13
        PYRAMID_14
        WEDGE_6
        WEDGE_15
        WEDGE_18
        HEX_8
        HEX_20
        HEX_27
        END_TOPOLOGY

cdef extern from "stk_topology/topology.hpp" namespace "stk" nogil:
    cdef cppclass topology:
        bool is_valid() const
        string name() const
        rank_t rank() const
        topology_t value() const


cdef class StkTopology:
    cdef topology topo

    @staticmethod
    cdef wrap_instance(topology topo)

