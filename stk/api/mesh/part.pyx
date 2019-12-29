# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from cython.operator cimport dereference as deref
from ..topology.topology cimport StkTopology, topology, topology_t
from .selector cimport *
from . cimport meta

cdef class StkPart:
    """stk::mesh::Part

    .. code-block:: python

       # Create a new part and set I/O attribute on that part
       new_part = meta.declare_part("fluid", rank_t.ELEM_RANK)
       new_part.set_io_attribute(set_io=True)

       # Retrive a part from a mesh
       part = meta.get_part("blade-HEX")

       # Get selector for a part and locally owned
       sel_local = part & meta.locally_owned_part

       # Get selector for all entities in the MPI partition
       sel_all = part & (meta.locally_owned_part | meta.globally_shared_part)
    """

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
        """Does the part exist in the MetaData

        Return:
            bool: If True, ``meta.get_part(...)`` returned ``nullptr``
        """
        return (self.part == NULL)

    @property
    def supersets(self):
        """Supersets of this part

        Return:
            list: List of super parts
        """
        cdef const PartVector* sset = &deref(self.part).supersets()
        cdef size_t nparts = deref(sset).size()
        cdef list plist = []
        for i in range(nparts):
            plist.append(StkPart.wrap_instance(deref(sset)[i]))
        return plist

    @property
    def subsets(self):
        """Subsets of this part

        Return:
            list: List of sub-parts
        """
        cdef const PartVector* sset = &deref(self.part).subsets()
        cdef size_t nparts = deref(sset).size()
        cdef Part* pp
        cdef list plist = []
        for i in range(nparts):
            plist.append(StkPart.wrap_instance(deref(sset)[i]))
        return plist

    @property
    def is_io_part(self):
        """Return True if this part is an I/O part"""
        is_part_io_part(deref(self.part))

    def set_toplogy(self, topology_t topo):
        """Set the topology type for a newly created part"""
        cdef topology topotmp = topology(topo)
        meta.set_topology(deref(self.part), topotmp)

    def set_io_attribute(self, set_io=True):
        """Set the I/O attribute for this part.

        Args:
            set_io (bool): If True add to I/O, else remove from I/O
        """
        if set_io:
            put_io_part_attribute(deref(self.part))
        else:
            remove_io_part_attribute(deref(self.part))

    def contains(self, StkPart part):
        """Is the part containined within this part"""
        return deref(self.part).contains(deref(part.part))

    def __repr__(self):
        if self.part == NULL:
            return "<StkPart: NULL>"
        else:
            return "<StkPart: %s>"%self.name

    def __and__(StkPart self, other):
        """Return a selector that is the intersection of this part and other"""
        cdef Part* spart = self.part
        cdef StkSelector stmp
        cdef StkPart ptmp

        cdef StkSelector py_snew = StkSelector.__new__(StkSelector)
        cdef Selector snew

        if isinstance(other, StkSelector):
            stmp = other
            snew = (deref(self.part) & stmp.sel)
            py_snew.sel = snew
            return py_snew
        elif isinstance(other, StkPart):
            ptmp = other
            snew = (deref(self.part) & deref(ptmp.part))
            py_snew.sel = snew
            return py_snew
        return NotImplemented

    def __or__(StkPart self, other):
        """Return a selector that is a union if this part and other"""
        cdef Part* spart = self.part
        cdef StkSelector stmp
        cdef StkPart ptmp

        cdef StkSelector py_snew = StkSelector.__new__(StkSelector)
        cdef Selector snew

        if isinstance(other, StkSelector):
            stmp = other
            snew = (deref(self.part) | stmp.sel)
            py_snew.sel = snew
            return py_snew
        elif isinstance(other, StkPart):
            ptmp = other
            snew = (deref(self.part) | deref(ptmp.part))
            py_snew.sel = snew
            return py_snew
        return NotImplemented
