df = spark.table("samples.nyctaxi.trips").limit(1000)
df.write.mode("overwrite").saveAsTable("workspace.digires_test.trips_copy")
print(f"Copied {df.count()} rows")