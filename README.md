# carrying_crate
 Garry's Mod addon that adds useful carrying crates for sandbox and roleplay usage.

**List of serverside console variables:**
| **Variable**                            | **Default Value** | **Minimum Value** | **Maximum Value** | **Description**                                                                                                                                                                                                                                                                  |
|-----------------------------------------|-------------------|-------------------|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| carrying_crate_max_connected_ents       | 6                 | 1                 | 65535             | The number of entities connected to a secured prop that will also be parented to the crate. Good for controlling performance, as large contraptions will cause lag spikes when parented all at once. Some contraptions are not physically stable when being unloaded.            |
| carrying_crate_force_mass_accumulation  | 0                 | 0                 | 2                 | 0 = Entity's choice. 1 = Force mass acumulation for all crates. 2 = Disable mass accumulation for all crates. This determines if the crate's physical weight is changed to equal its contents, since parenting removes physics.                                                  |
| carrying_crate_force_content_validation | 0                 | 0                 | 2                 | Content validation checks to see if the prop trying to be carried has its center of mass within the crate boundaries. If it is not then it will not be carried. 0 = Entity's choice. 1 = Force content validation for all crates. 2 = Disable content validation for all crates. |
