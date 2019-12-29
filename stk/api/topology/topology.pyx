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
        """Boolean indicating whether the topology is valid"""
        return self.topo.is_valid()

    @property
    def name(self):
        """Name of the topology"""
        cdef string tname = self.topo.name()
        return tname.decode('UTF-8')

    @property
    def rank(self):
        """Entity rank"""
        return self.topo.rank()

    @property
    def value(self):
        """Topology type"""
        return self.topo.value()

    def __eq__(StkTopology self, other):
        """Equality comparison"""
        cdef StkTopology stopo
        cdef topology topo
        cdef topology_t topo_t
        if isinstance(other, StkTopology):
            stopo = other
            topo = stopo.topo
            return self.topo == topo
        elif isinstance(other, topology_t):
            topo_t = other
            return self.topo == topo_t
        return NotImplemented
