# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

cdef rank_to_pyrank(rank_t rank):
    """Return a wrapped python rank

    Args:
        rank (stk::topology::rank_t): C++ rank enum
    """
    if rank == NODE_RANK:
        return StkRank.node
    elif rank == EDGE_RANK:
        return StkRank.edge
    elif rank == FACE_RANK:
        return StkRank.face
    elif rank == ELEM_RANK:
        return StkRank.elem
    else:
        raise RuntimeError("Invalid rank provided")

cdef pyrank_to_rank(StkRank rank):
    """Retrieve STK rank from wrapped python"""
    if rank == StkRank.node:
        return NODE_RANK
    elif rank == StkRank.edge:
        return EDGE_RANK
    elif rank == StkRank.face:
        return FACE_RANK
    elif rank == StkRank.elem:
        return ELEM_RANK
    else:
        raise RuntimeError("Invalid rank provided")


cdef class StkTopology:

    @staticmethod
    cdef wrap_instance(topology topo):
        cdef StkTopology stopo = StkTopology.__new__(StkTopology)
        stopo.topo = topo
        return stopo

    @property
    def is_valid(self):
        return self.topo.is_valid()

    @property
    def name(self):
        cdef string tname = self.topo.name()
        return tname.decode('UTF-8')

    @property
    def rank(self):
        return rank_to_pyrank(self.topo.rank())

    @property
    def value(self):
        return self.topo.value()
