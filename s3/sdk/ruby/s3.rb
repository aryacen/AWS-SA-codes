# Importing necessary libraries:
require 'aws-sdk-s3'    # AWS SDK for Ruby, specifically for interacting with Amazon S3
require 'pry'           # Pry is a runtime developer console and IRB alternative
require 'securerandom'  # SecureRandom is a module that provides methods for generating random numbers

# Fetching the bucket name from the environment variables. This assumes that the environment variable 'BUCKET_NAME' is set.
bucket_name = ENV['BUCKET_NAME']

# Specifying the AWS region where the S3 bucket will be created.
region = 'ap-southeast-2'

# Initializing an S3 client. This client will be used to interact with Amazon S3.
client = Aws::S3::Client.new

# Creating an S3 bucket using the specified bucket name and region.
resp = client.create_bucket({
    bucket: bucket_name,
    create_bucket_configuration: {
        location_constraint: region
    }
})

# Ensure the tmp directory exists before creating files in it
Dir.mkdir('tmp') unless Dir.exist?('tmp')

# Generating a random number of files to be created and uploaded to the S3 bucket.
number_of_files = 1 + rand(6)  # Randomly selects a number between 1 and 6 (inclusive)
puts "number_of_files: #{number_of_files}"  # Outputting the number of files to be created

# Looping through the number of files to create and upload them to S3
number_of_files.times.each do |i|

    # Defining the filename and the output path for the file to be created.
    filename = "file_#{i}.txt"          # The name of the file to be uploaded to S3
    output_path = "tmp/#{filename}"   # Local path where the file will be created

    # Creating a file at the specified path and writing a unique UUID to it.
    File.open(output_path, "w") do |f|
        f.write(SecureRandom.uuid)  # Generating and writing a UUID to the file
    end

    # Reopening the file in read-binary mode to upload it to S3.
    File.open(output_path, "rb") do |f|
        # Uploading the file to the S3 bucket with the generated filename.
        client.put_object(
            bucket: bucket_name,
            key: filename,
            body: f
        )
    end
end
