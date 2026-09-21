# Week 4 - the submitted files

Canvas has three Week 4 assignments, so there is one script and one testing
document per item. Run the scripts on your VM in this order, each one as a
whole file with F5 (File > Open, not copy/paste):

1. `Week4_Item1_StoredProcedures.sql` - the five spN_ procs (1a-1e) plus the
   SupplierIngredients table 1a needs
2. `Week4_Item2_Indexes.sql` - the six indexes
3. `Week4_Item3_CRUD.sql` - the eight CRUD procs on Charities and KitchenDetails

Every script drops and recreates its own objects, so re-running is safe, and
the TESTING section at the bottom of each one leaves the tables exactly as it
found them (15 charities, 5 kitchens).

`Week4_Deliverables.sql` is the same code as all three in one file, for
building a fresh VM in one go.

Everyone's original Week 4 files are untouched in `Mason/`, `Nathan/` and
`Nicholas/`. The merged versions here differ from those only where something
did not run or a project requirement needed it (proc names, GO batches, the
1e parameter, returning a row from update/delete).
