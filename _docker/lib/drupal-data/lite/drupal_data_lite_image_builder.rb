require_relative '../../../lib/process_runner'

#
# This class helps to generate a new version of the drupal-data-lite Docker Image and then push this image up to DockerHub.
#
# This class uses the 'builder' pattern for the generation of the Docker image. Namely it executes a Docker container that
# generates files that are written to a volume. It then takes the generated files and copies them into a Docker Image before
# pushing that image to Docker Hub.
#
# We need to implement the builder pattern for creating the drupal-data-lite image due to the increasing size of the
# production database dump. There is no way to manipulate the database dump without utilising all of the available
# filesystem space within the container. Instead of giving the container more filesystem space, we solve it permanently here
# by adopting the builder pattern.
#
# @author rblake@redhat.com
#
class DrupalDataLiteImageBuilder

  def initialize(working_directory, process_runner)
    @working_directory = working_directory
    @process_runner = process_runner
  end

  #
  # Generates a new version of the redhatdeveloper/drupal-data-lite image
  #
  def generate_lite_data_image
    clean_working_directory
    generate_lite_database_dump
    build_lite_data_image
    push_lite_data_image
    clean_working_directory
  end

  private

  #
  # Cleans up the working directory of any previous run
  #
  def clean_working_directory
    @process_runner.execute!("rm -rf #{@working_directory}/work")
  end

  #
  # Runs a Docker container to generate the "lite" database dump. The dump is written to the working directory where it can then be
  # built into a Docker container image by through `docker build`
  #
  def generate_lite_database_dump
    @process_runner.execute!("mkdir #{@working_directory}/work")
    @process_runner.execute!('docker pull redhatdeveloper/drupal-data:latest')
    @process_runner.execute!("docker run --rm -v #{@working_directory}/work:/work redhatdeveloper/drupal-data:latest /bin/sh -c \"gzip -d -c /docker-entrypoint-initdb.d/drupal-db.sql.gz > /work/drupal-db.sql &&  awk '!/INSERT INTO \\`node_revision__body\\`/' /work/drupal-db.sql | gzip > /work/drupal-db.sql.gz && rm -f /work/drupal-db.sql && chmod 777 /work/drupal-db.sql.gz\"")
  end

  #
  # Builds the new version of the "lite" data image and tags it as redhatdeveloper/drupal-data-lite:latest
  #
  def build_lite_data_image
    @process_runner.execute!("cd #{@working_directory} && docker build -t redhatdeveloper/drupal-data-lite:latest -f Dockerfile.lite .")
  end

  #
  # Pushes the new version of the redhatdeveloper/drupal-data-lite:latest image up to DockerHub.
  #
  def push_lite_data_image
    @process_runner.execute!('docker push redhatdeveloper/drupal-data-lite:latest')
  end

end