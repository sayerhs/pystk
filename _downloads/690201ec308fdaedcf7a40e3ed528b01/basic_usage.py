# -*- coding: utf-8 -*-

"""\
Basic usage of pySTK interface
==============================

This tutorial provides a high-level overview of using pySTK API to interact with
Exodus-II databases and the Sierra Toolkit library.

The main entry point is the StkMesh instance which is a Python-wrapper that
holds the MetaData, BulkData, and StkMeshIoBroker instances. The user can
create multiple instances of StkMesh to manipulate different meshes.

Every class in STK (e.g., MetaData, BulkData, Part, Selector, etc.) has a
python wrapped counterpart with the `Stk` prefix. For example, `MetaData` is
exposed as `StkMetaData` within the python layer

"""

import numpy as np
import stk
from stk import StkMesh, Parallel, StkState, StkSelector, StkRank


par = Parallel.initialize()
print("MPI: rank = %d; size = %d"%(par.rank, par.size))

# Create a STK mesh instance that holds MetaData and BulkData
mesh = StkMesh(par, ndim=3)


mesh.read_mesh_meta_data(
    "periodic3d.g",
    purpose=stk.DatabasePurpose.READ_MESH,
    auto_decomp=True,
    auto_decomp_type="rcb")

# Equivalent statement as above
# mesh.read_mesh_meta_data("periodic3d.g")

# At this point the mesh metadata has been read in, but the bulk data hasn't
# been populated yet. The metadata is open for modification, i.e., the user can
# add parts, fields, etc.

# Register fields
pressure = mesh.meta.declare_scalar_field("pressure")
velocity = mesh.meta.declare_vector_field("velocity", number_of_states=3)

# Fields of type other than `double` can be declared with special syntax
iblank = mesh.meta.declare_scalar_field_t[int]("iblank")

# Register the fields on desired parts
pressure.add_to_part(mesh.meta.universal_part,
                     init_value=np.array([20.0]))
velocity.add_to_part(mesh.meta.universal_part,
                     mesh.meta.spatial_dimension,
                     init_value=np.array([10.0, 0.0, 0.0]))
iblank.add_to_part(mesh.meta.universal_part)

# Commit the metadata and load the mesh. Also create edges at this point (default is False)
mesh.populate_bulk_data(create_edges=True)
print("Metadata is committed: ", mesh.meta.is_committed)

# Access the coordinate field
coords = mesh.meta.coordinate_field
print("Coordinates field: ", coords.name)

# Access different field states
velold = velocity.field_state(StkState.StateNM1)
print("velocity NM1 name: ", velold.name)

# Access a part by name
part = mesh.meta.get_part("surface_1")
print("Part exists = ", (not part.is_null))

# Get a stk::mesh::Selector instance from this part
sel_part = StkSelector.from_part(part)

# Get the selector for entities on `surface_1` locally owned on this rank
sel = StkSelector.and_(part, mesh.meta.locally_owned_part)

# Check if the selector is empty for a particular entity type
print("Surface1 has elems: ", not sel.is_empty(StkRank.ELEM_RANK))

###
### Common looping concepts
###

# Iterating over entities
count = 0
miny = 1.0e6
maxy = -1.0e6
for node in mesh.iter_entities(sel, StkRank.NODE_RANK):
    count += 1
    xyz = coords.get(node)
    miny = min(miny, xyz[1])
    maxy = max(maxy, xyz[1])

print("Num. nodes = ", count, "; miny = ", miny, "; maxy = ", maxy)

# Interating and acting over entire buckets
for bkt in mesh.iter_buckets(sel, StkRank.NODE_RANK):
    vel = velocity.bkt_view(bkt)
    pres = pressure.bkt_view(bkt)
    vel[:, -1] = pres[:]

del mesh
par.finalize()
