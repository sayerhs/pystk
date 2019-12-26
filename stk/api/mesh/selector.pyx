# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from cython.operator cimport dereference as deref
from ..topology cimport topology

cdef class StkSelector:
    """stk::mesh::Selector

    StkSelector provides the most used features of ``stk::mesh::Selector``
    through its methods.

    .. code-block:: python

       # Get default sideset names for a generated mesh
       part_names = ("surface_%d"%(i+1) for i in range (6))
       parts = [mesh.get_part(pname) for pname in part_names]
       sel = StkSelector.and_(
           StkSelector.select_union(parts),
           mesh.locally_owned_part)

       # Does this selector contain any element entities?
       print(sel.is_empty(StkEntity.elem))
       # Does the complement contain element entities?
       print(sel.complement().is_empty(StkEntity.elem))
    """

    @staticmethod
    def from_part(StkPart part):
        """Create a selector from part

        Args:
            part (StkPart): Part instance

        Return:
            StkSelector: Newly created selector instance
        """
        cdef StkSelector sel = StkSelector.__new__(StkSelector)
        sel.sel = Selector(deref(part.part))
        return sel

    @staticmethod
    def select_field(StkFieldBase field):
        """Create a selector from a field instance

        Equivalent to ``stk::mesh::selectField``

        Args:
            field (StkFieldBase): Field instance

        Return:
            StkSelector: Newly created selector instance
        """
        cdef StkSelector sel = StkSelector.__new__(StkSelector)
        sel.sel = Selector(deref(field.fld))
        return sel

    @staticmethod
    def select_union(parts):
        """Create STK Selector from a list of parts

        Args:
            parts (list): A list of StkPart instances

        Return:
            StkSelector: Python-wrapped STK selector instance
        """
        cdef PartVector pvec
        cdef StkPart pp
        for pp in parts:
            pvec.push_back(pp.part)
        cdef StkSelector sel = StkSelector.__new__(StkSelector)
        sel.sel = selectUnion(pvec);
        return sel

    @staticmethod
    def select_intersection(parts):
        """Create STK selector from intersection of given parts

        Args:
            parts (list): A list of StkPart instances

        Return:
            StkSelector: Python-wrapped STK selector instance
        """
        cdef PartVector pvec
        cdef StkPart pp
        for pp in parts:
            pvec.push_back(pp.part)
        cdef StkSelector sel = StkSelector.__new__(StkSelector)
        sel.sel = selectIntersection(pvec);
        return sel


    @staticmethod
    def and_(sel1, *args):
        """Get an intersection of selectors

        The arguments can either be :class:`~stk.api.mesh.part.Part` or
        :class:`~stk.api.mesh.selector.StkSelector` instances.

        Return:
            StkSelector: Newly created selector instance
        """
        cdef Selector sel
        cdef StkSelector stmp
        cdef StkPart ptmp
        if isinstance(sel1, StkSelector):
            stmp = sel1
            sel = stmp.sel
        elif isinstance(sel1, StkPart):
            ptmp = sel1
            sel = Selector(deref(ptmp.part))
        else:
            raise ValueError("Need selector, got %s"%sel1)

        for ss in args:
            if isinstance(ss, StkSelector):
                stmp = ss
                sel = (sel & stmp.sel)
            elif isinstance(ss, StkPart):
                ptmp = ss
                sel = (sel & deref(ptmp.part))
            else:
                raise ValueError("Need selector, got %s"%sel1)

        cdef StkSelector psel = StkSelector.__new__(StkSelector)
        psel.sel = sel
        return psel

    @staticmethod
    def or_(sel1, *args):
        """Get a union of selectors

        The arguments can either be :class:`~stk.api.mesh.part.Part` or
        :class:`~stk.api.mesh.selector.StkSelector` instances.

        Return:
            StkSelector: Newly created selector instance
        """
        cdef Selector sel
        cdef StkSelector stmp
        cdef StkPart ptmp
        if isinstance(sel1, StkSelector):
            stmp = sel1
            sel = stmp.sel
        elif isinstance(sel1, StkPart):
            ptmp = sel1
            sel = Selector(deref(ptmp.part))
        else:
            raise ValueError("Need selector, got %s"%sel1)

        for ss in args:
            if isinstance(ss, StkSelector):
                stmp = ss
                sel = (sel | stmp.sel)
            elif isinstance(ss, StkPart):
                ptmp = ss
                sel = (sel | deref(ptmp.part))
            else:
                raise ValueError("Need selector, got %s"%sel1)

        cdef StkSelector psel = StkSelector.__new__(StkSelector)
        psel.sel = sel
        return psel

    def complement(self):
        """Return !(selector)"""
        cdef Selector sel = self.sel.complement()
        cdef StkSelector psel = StkSelector.__new__(StkSelector)
        psel.sel = sel
        return psel

    def is_empty(self, topology.rank_t rank):
        """Check if the selector contains entities of a given rank

        Args:
            rank (rank_t): Entity rank

        Return:
            bool: True if the selector does not contain entities of the given rank
        """
        return self.sel.is_empty(rank)

    def __and__(StkSelector self, other):
        """Return the intersection of two given selectors/parts"""
        cdef Selector sthis = self.sel
        cdef StkSelector stmp
        cdef StkPart ptmp

        cdef StkSelector py_snew = StkSelector.__new__(StkSelector)
        cdef Selector snew

        if isinstance(other, StkSelector):
            stmp = other
            snew = (sthis & stmp.sel)
            py_snew.sel = snew
            return py_snew
        elif isinstance(other, StkPart):
            ptmp = other
            snew = (sthis & deref(ptmp.part))
            py_snew.sel = snew
            return py_snew
        return NotImplemented

    def __or__(StkSelector self, other):
        """Return the intersection of two given selectors/parts"""
        cdef Selector sthis = self.sel
        cdef StkSelector stmp
        cdef StkPart ptmp

        cdef StkSelector py_snew = StkSelector.__new__(StkSelector)
        cdef Selector snew

        if isinstance(other, StkSelector):
            stmp = other
            snew = (sthis | stmp.sel)
            py_snew.sel = snew
            return py_snew
        elif isinstance(other, StkPart):
            ptmp = other
            snew = (sthis | deref(ptmp.part))
            py_snew.sel = snew
            return py_snew
        return NotImplemented
