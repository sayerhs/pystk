# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

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
        return self.topo.rank()

    @property
    def value(self):
        return self.topo.value()
