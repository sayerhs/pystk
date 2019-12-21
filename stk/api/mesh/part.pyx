# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from cython.operator cimport dereference as deref
from ..topology.topology cimport StkTopology, topology

cdef class StkPart:
    """stk::mesh::Part """

    def __cinit__(self):
        self.part = NULL

    @staticmethod
    cdef wrap_instance(Part* part):
        cdef StkPart spart = StkPart.__new__(StkPart)
        spart.part = part
        return spart

    @property
    def name(self):
        """Name of the STK part object"""
        assert(self.part != NULL)
        return deref(self.part).name().decode('UTF-8')

    @property
    def topology(self):
        """Topology of the STK part object"""
        assert(self.part != NULL)
        cdef topology topo = deref(self.part).topology()
        return StkTopology.wrap_instance(topo)

    @property
    def part_id(self):
        """Unique part identifier

        For IO part, this number is greater than 0
        """
        assert (self.part != NULL), "Invalid part encountered"
        return deref(self.part).part_id()

    @property
    def is_null(self):
        """Check if the part is null"""
        return (self.part == NULL)

    @property
    def supersets(self):
        """Supersets of this part"""
        cdef const PartVector* sset = &deref(self.part).supersets()
        cdef size_t nparts = deref(sset).size()
        cdef list plist = []
        for i in range(nparts):
            plist.append(StkPart.wrap_instance(deref(sset)[i]))
        return plist

    @property
    def subsets(self):
        """Subsets of this part"""
        cdef const PartVector* sset = &deref(self.part).subsets()
        cdef size_t nparts = deref(sset).size()
        cdef Part* pp
        cdef list plist = []
        for i in range(nparts):
            plist.append(StkPart.wrap_instance(deref(sset)[i]))
        return plist

    def contains(self, StkPart part):
        """Is the part containined within this part"""
        return deref(self.part).contains(deref(part.part))

    def __repr__(self):
        return "<StkPart: %s>"%self.name
