# Interior edges to group
# Merges faces while retaining a copy of the purged edges in a group.
# Useful in my laser cutting workflow where I want to manage these edges separately for engraving

model = Sketchup.active_model
entities = model.active_entities
selection = model.selection

model.start_operation("Interior Edges to Group")

subject = selection.empty? ? entities.to_a : selection.to_a
# TODO: Use more reliable check for flat edges
interior_edges = subject.grep(Sketchup::Edge).select { |e| e.faces.size == 2 && e.faces[0].normal.parallel?(e.faces[1].normal) }
p interior_edges
old_entities = entities.to_a
group = entities.add_group(interior_edges)

### # SketchUp create new edges in place of those grouped
### new_entities = entities.to_a - old_entities
### p new_entities
### entities.erase_entities(new_entities - [group])

entities.erase_entities(interior_edges)

# TODO: Line up axes with parent?

model.commit_operation