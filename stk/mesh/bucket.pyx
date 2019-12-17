# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from cython.operator cimport dereference as deref
from .stk_mesh_fwd cimport EntityRank
from ..topology.topology cimport StkTopology, rank_to_pyrank

cdef class StkBucket:
    """stk::mesh::Bucket"""

    def __cinit__(self):
        self.bkt = NULL

    @staticmethod
    cdef wrap_instance(Bucket* bkt):
        cdef StkBucket sbkt = StkBucket.__new__(StkBucket)
        sbkt.bkt = bkt
        return sbkt

    @property
    def topology(self):
        """Topology of this STK bucket instance"""
        cdef topo_cls topo = deref(self.bkt).topology()
        return StkTopology.wrap_instance(topo)

    @property
    def owned(self):
        """Does this bucket consist of owned entities"""
        return deref(self.bkt).owned()

    @property
    def shared(self):
        """Does this bucket contain shared entities"""
        return deref(self.bkt).shared()

    @property
    def in_aura(self):
        """Is this an aura bucket"""
        return deref(self.bkt).in_aura()

    @property
    def size(self):
        """Number of entities in this bucket"""
        return deref(self.bkt).size()

    @property
    def bucket_id(self):
        """Bucket identifier"""
        return deref(self.bkt).bucket_id()

    @property
    def entity_rank(self):
        """EntityRank"""
        return rank_to_pyrank(deref(self.bkt).entity_rank())
