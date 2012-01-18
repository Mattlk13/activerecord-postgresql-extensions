
$: << File.dirname(__FILE__)
require 'test_helper'

class GeometryTests < Test::Unit::TestCase
  include PostgreSQLExtensionsTestHelper

  def test_create_geometry
    Mig.create_table(:foo) do |t|
      t.geometry :the_geom, :srid => 4326
    end

    assert_equal([
      %{CREATE TABLE "foo" (
  "id" serial primary key,
  "the_geom" geometry,
  CONSTRAINT "enforce_srid_the_geom" CHECK (srid("the_geom") = (4326)),
  CONSTRAINT "enforce_dims_the_geom" CHECK (ndims("the_geom") = 2)
);},
  %{DELETE FROM "geometry_columns" WHERE f_table_catalog = '' AND f_table_schema = 'public' AND f_table_name = 'foo' AND f_geometry_column = 'the_geom';},
  %{INSERT INTO "geometry_columns" VALUES ('', 'public', 'foo', 'the_geom', 2, 4326, 'GEOMETRY');},
  %{CREATE INDEX "foo_the_geom_gist_index" ON "foo" USING "gist"("the_geom");}
    ], statements)
  end

  def test_create_geometry_with_schema
    Mig.create_table('public.foo') do |t|
      t.geometry :the_geom, :srid => 4326
    end

    assert_equal([
      %{CREATE TABLE "public"."foo" (
  "id" serial primary key,
  "the_geom" geometry,
  CONSTRAINT "enforce_srid_the_geom" CHECK (srid("the_geom") = (4326)),
  CONSTRAINT "enforce_dims_the_geom" CHECK (ndims("the_geom") = 2)
);},
  %{DELETE FROM "geometry_columns" WHERE f_table_catalog = '' AND f_table_schema = 'public' AND f_table_name = 'foo' AND f_geometry_column = 'the_geom';},
  %{INSERT INTO "geometry_columns" VALUES ('', 'public', 'foo', 'the_geom', 2, 4326, 'GEOMETRY');},
  %{CREATE INDEX "foo_the_geom_gist_index" ON "foo" USING "gist"("the_geom");}
    ], statements)
  end

  def test_create_geometry_with_not_null
    Mig.create_table(:foo) do |t|
      t.geometry :the_geom, :srid => 4326, :null => false
    end

    assert_equal([
      %{CREATE TABLE "foo" (
  "id" serial primary key,
  "the_geom" geometry NOT NULL,
  CONSTRAINT "enforce_srid_the_geom" CHECK (srid("the_geom") = (4326)),
  CONSTRAINT "enforce_dims_the_geom" CHECK (ndims("the_geom") = 2)
);},
  %{DELETE FROM "geometry_columns" WHERE f_table_catalog = '' AND f_table_schema = 'public' AND f_table_name = 'foo' AND f_geometry_column = 'the_geom';},
  %{INSERT INTO "geometry_columns" VALUES ('', 'public', 'foo', 'the_geom', 2, 4326, 'GEOMETRY');},
  %{CREATE INDEX "foo_the_geom_gist_index" ON "foo" USING "gist"("the_geom");}
    ], statements)
  end

  def test_create_geometry_with_null_and_type
    Mig.create_table(:foo) do |t|
      t.geometry :the_geom, :srid => 4326, :geometry_type => :polygon
    end

    assert_equal([
      %{CREATE TABLE "foo" (
  "id" serial primary key,
  "the_geom" geometry,
  CONSTRAINT "enforce_srid_the_geom" CHECK (srid("the_geom") = (4326)),
  CONSTRAINT "enforce_dims_the_geom" CHECK (ndims("the_geom") = 2),
  CONSTRAINT "enforce_geotype_the_geom" CHECK (geometrytype("the_geom") = 'POLYGON'::text OR "the_geom" IS NULL)
);},
  %{DELETE FROM "geometry_columns" WHERE f_table_catalog = '' AND f_table_schema = 'public' AND f_table_name = 'foo' AND f_geometry_column = 'the_geom';},
  %{INSERT INTO "geometry_columns" VALUES ('', 'public', 'foo', 'the_geom', 2, 4326, 'POLYGON');},
  %{CREATE INDEX "foo_the_geom_gist_index" ON "foo" USING "gist"("the_geom");}
    ], statements)
  end
end