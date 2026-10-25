
# Import required libraries
require 'aws-sdk-s3'   # AWS SDK for interacting with Amazon S3
require 'pry'          # Debugging tool for Ruby
require 'securerandom' # Generates random unique identifiers (UUIDs)

# Retrieve the bucket name from an environment variable.
# This allows the script to use different bucket names without
# modifying the source code.
bucket_name = ENV.fetch('BUCKET_NAME')

# Define the AWS region where the bucket will be created.
region = ENV.fetch('AWS_REGION', 'us-east-1')

# Initialize an Amazon S3 client.
# The SDK automatically looks for AWS credentials using
# its default credential provider chain.
client = Aws::S3::Client.new(region: region)

# Define bucket creation parameters.
params = {
  bucket: bucket_name
}

# LocationConstraint is required outside us-east-1.
if region != 'us-east-1'
  params[:create_bucket_configuration] = {
    location_constraint: region
  }
end

# Create bucket.
client.create_bucket(params)

# Generate a random number between 1 and 6.
# This determines how many files will be uploaded to the bucket.
number_of_files = 1 + rand(6)

puts "number_of_files: #{number_of_files}"

# Repeat the following operations for each file.
number_of_files.times.each do |i|

  # Display the current iteration.
  puts "i: #{i}"
  filename = "file_#{i}.txt" # Generate a unique filename for each iteration.
  output_path = "/tmp/#{filename}" # Define the temporary local path where the file will be stored.

  # Each file contains a randomly generated UUID.
  File.open(output_path, "w") do |f|
    f.write SecureRandom.uuid
  end

  # Open the generated file in binary read mode.
  File.open(output_path, 'rb') do |f|

    # Upload the file to the S3 bucket.
    # bucket: Destination S3 bucket
    # key: Object name inside the bucket
    # body: File contents to upload
    client.put_object(
      bucket: bucket_name,
      key: filename,
      body: f
    )
  end
end
