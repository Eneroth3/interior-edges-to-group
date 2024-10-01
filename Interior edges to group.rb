# Interior edges to group
# Merges faces while retaining a copy of the purged edges in a group.
# Useful in my laser cutting workflow where I want to manage these edges separately for engraving

def group_interior_edges
  model = Sketchup.active_model
  entities = model.active_entities
  selection = model.selection

  model.start_operation("Group Interior Edges")

  subject = selection.empty? ? entities.to_a : selection.to_a
  interior_edges =
    subject.grep(Sketchup::Edge).select { |e| e.faces.size == 0 || coplanar_edge?(e)  }

  # old_entities = entities.to_a

  # Creating a group from existing entities only works reliably in the active
  # entities. Hence we don't pass entities or edges as arguments to this method,
  # but limit it to the current selection.
  group = entities.add_group(interior_edges)

  #I thought SketchUp moved the existing entities into a group and creaed new
  ### new_entities = entities.to_a - old_entities
  ### entities.erase_entities(new_entities - [group])

  # Turns out SketchU places the copied entities in the group and retains the
  # original entities where they were.
  entities.erase_entities(interior_edges)

  # TODO: Line up axes with parent (drawing axes)?

  model.commit_operation
end

# TODO: Copy to community lib

# Test if the two faces around an edge or planar, i.e. if the edge can be erased
# and SketchUp merging the faces into one.
#
# @param edge [SketchUp::Edge]
#
# @return [Boolean]
def coplanar_edge?(edge)
  return false unless edge.faces.size == 2

  # TODO: Use more reliable check from Upright Extruder for close to coplanar faces.
  edge.faces[0].normal.parallel?(edge.faces[1].normal)
end


# TODO: Add menu entry. Now just calling the method directly.
group_interior_edges
