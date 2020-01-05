# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from cython.operator cimport dereference as deref

cdef class StkGhosting:
    """stk::mesh::Ghosting """

    def __cinit__(self):
        self.ghosting = NULL

    @staticmethod
    cdef wrap_instance(Ghosting* ghosting):
        cdef StkGhosting sghost = StkGhosting.__new__(StkGhosting)
        sghost.ghosting = ghosting
        return sghost

    @staticmethod
    cdef wrap_reference(Ghosting& ghosting):
        cdef StkGhosting sghost = StkGhosting.__new__(StkGhosting)
        sghost.ghosting = &ghosting
        return sghost

    @property
    def name(self):
        """Name of the ghosting instance"""
        assert (self.ghosting != NULL)
        return deref(self.ghosting).name().decode('UTF-8')

    @property
    def ordinal(self):
        """Unique ordinal to identify ghosting subset"""
        return deref(self.ghosting).ordinal()
