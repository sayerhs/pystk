# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

cdef class StkEntity:
    """stk::mesh::Entity"""

    @staticmethod
    cdef wrap_instance(Entity entity):
        cdef StkEntity sentity = StkEntity.__new__(StkEntity)
        sentity.entity = entity
        return sentity

    @property
    def local_offset(self):
        """Return the local offset of this entity"""
        return self.entity.local_offset()

    @property
    def is_local_offset_valid(self):
        return self.entity.is_local_offset_valid()
