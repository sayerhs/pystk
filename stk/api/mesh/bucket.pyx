# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from cython.operator cimport dereference as deref
from .stk_mesh_fwd cimport EntityRank
from ..topology.topology cimport StkTopology
from .entity cimport StkEntity, Entity

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
        """Entity rank corresponding to this bucket"""
        return deref(self.bkt).entity_rank()

    def __getitem__(self, int idx):
        """Return entity using the index"""
        assert 0 <= idx < self.size, "Invalid index for bucket (%s)"%self.size
        return StkEntity.wrap_instance(deref(self.bkt)[idx])

    def __iter__(self):
        """Return an iterator for looping over bucket entities"""
        cdef size_t i
        cdef size_t bsize = self.size
        cdef StkEntity sent = StkEntity()
        cdef Bucket* bkt = self.bkt
        for i in range(bsize):
            sent.entity = <Entity>deref(bkt)[i]
            yield sent
