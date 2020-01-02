# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from cython.operator cimport dereference as deref
from libcpp cimport bool
from ..util.parallel cimport Parallel
from ..topology.topology cimport rank_t
from .entity cimport StkEntity
from .selector cimport StkSelector
from .bucket cimport StkBucket
from .part cimport StkPart
from .meta cimport StkMetaData

cdef class StkBulkData:
    """stk::mesh::BulkData"""

    def __cinit__(self):
        self.bulk = NULL
        self.bulk_owner = False

    def __dealloc__(self):
        if self.bulk is not NULL and self.bulk_owner is True:
            del self.bulk

    def __eq__(self, StkBulkData other):
        return self.bulk == other.bulk

    @staticmethod
    cdef wrap_instance(BulkData* in_bulk, bint owner=False):
        cdef StkBulkData sbulk = StkBulkData.__new__(StkBulkData)
        sbulk.bulk = in_bulk
        sbulk.bulk_owner = owner
        return sbulk

    @staticmethod
    def create(StkMetaData smeta, Parallel par):
        """Create a BulkData instance

        Args:
            smeta (StkMetaData): MetaData instance to create Bulkdata
            par (Parallel): Parallel communicator object

        Return:
            StkBulkData: Newly created BulkData
        """
        cdef BulkData* bulk = new BulkData(deref(smeta.meta), par.comm)
        return StkBulkData.wrap_instance(bulk)

    @property
    def meta(self):
        """MetaData associated with this bulk instance"""
        assert(self.bulk != NULL)
        return StkMetaData.wrap_instance(&(deref(self.bulk).mesh_meta_data()))

    @property
    def parallel(self):
        """Parallel communicator associated with this instance"""
        assert(self.bulk != NULL)
        cdef Parallel par = Parallel()
        par.comm = deref(self.bulk).parallel()
        par.size = deref(self.bulk).parallel_size()
        par.rank = deref(self.bulk).parallel_rank()
        return par

    @property
    def parallel_size(self):
        """Number of MPI ranks"""
        return deref(self.bulk).parallel_size()

    @property
    def parallel_rank(self):
        """Current MPI rank"""
        return deref(self.bulk).parallel_rank()

    @property
    def in_modifiable_state(self):
        """Is BulkData in a modification cycle"""
        return deref(self.bulk).in_modifiable_state()

    @property
    def in_synchronized_state(self):
        """Is BulkData in a modification cycle"""
        return deref(self.bulk).in_synchronized_state()

    @property
    def is_automatic_aura_on(self):
        """Flag indicating whether aura is on"""
        return deref(self.bulk).is_automatic_aura_on()

    @property
    def synchronized_count(self):
        """Synchronization counter"""
        return deref(self.bulk).synchronized_count()

    @property
    def get_max_allowed_id(self):
        """Maximum allowed entity ID"""
        return deref(self.bulk).get_max_allowed_id()

    def identifier(self, StkEntity entity):
        """Return the EntityID for the given entity"""
        return deref(self.bulk).identifier(entity.entity)

    def num_nodes(self, StkEntity entity):
        """Return the number of nodes for a given entity"""
        return deref(self.bulk).num_nodes(entity.entity)

    def num_edges(self, StkEntity entity):
        """Return the number of edges for a given entity"""
        return deref(self.bulk).num_edges(entity.entity)

    def num_faces(self, StkEntity entity):
        """Return the number of faces for a given entity"""
        return deref(self.bulk).num_faces(entity.entity)

    def num_elements(self, StkEntity entity):
        """Return the number of elements for a given entity"""
        return deref(self.bulk).num_elements(entity.entity)

    def bucket(self, StkEntity entity):
        """Get the bucket containing a given entity"""
        return StkBucket.wrap_instance(&deref(self.bulk).bucket(entity.entity))

    def bucket_ordinal(self, StkEntity entity):
        """Get the bucket ordinal containing the given entity"""
        return deref(self.bulk).bucket_ordinal(entity.entity)

    def parallel_owner_rank(self, StkEntity entity):
        """Return the owning MPI rank for the given entity"""
        return deref(self.bulk).parallel_owner_rank(entity.entity)

    def identifier(self, StkEntity entity):
        """Return a unique identifier for the given entity"""
        return deref(self.bulk).identifier(entity.entity)

    def iter_buckets(self, StkSelector sel, rank_t rank=rank_t.NODE_RANK):
        """Iterator for looping over STK buckets

        Args:
            sel (StkSelector): Selector for fetching the desired entities
            rank (rank_t): Entity rank

        Yield:
            StkBucket: Bucket instances
        """
        cdef StkBucket sbkt = StkBucket()
        cdef Selector ssel = sel.sel
        cdef BulkData* sbulk = self.bulk
        cdef const BucketVector* bkts = &(deref(self.bulk).get_buckets(rank, sel.sel))

        cdef size_t num_bkts = deref(bkts).size()
        cdef size_t i
        for i in range(num_bkts):
            sbkt.bkt = <Bucket*>deref(bkts)[i]
            yield sbkt

    def iter_entities(self, StkSelector sel, rank_t rank=rank_t.NODE_RANK):
        """Iterator for looping over STK buckets

        Args:
            sel (StkSelector): Selector for fetching the desired entities
            rank (rank_t): Entity rank

        Yield:
            StkEntity: entities
        """
        cdef Bucket* bkt
        cdef StkEntity ent = StkEntity()
        cdef const BucketVector* bkts = &(deref(self.bulk).get_buckets(rank, sel.sel))
        cdef size_t num_bkts = deref(bkts).size()
        cdef size_t bkt_size
        cdef size_t i, j

        for i in range(num_bkts):
            bkt = <Bucket*>deref(bkts)[i]
            bkt_size = deref(bkt).size()
            for j in range(bkt_size):
                ent.entity = deref(bkt)[j]
                yield ent
