########################################
# An environment to build our code

# This is the base image. We want to build our own
# image on top of this.
FROM bitnami/node:14.21.1 as build

# We set the container working directory to my-app
WORKDIR /my-app

# Next we add the node modules to the path on the image
ENV PATH /my-app/node_modules/.bin:$PATH

# We copy over our package.json and package-lock.json
COPY my-app/package.json ./
COPY my-app/package-lock.json ./

# We install our dependencies
RUN npm ci 
# RUN npm install react-scripts@3.4.1 -g 

# Copy over all of the files from our local machine and
# run the build command
COPY my-app/. ./
RUN npm run build

########################################
# An environment to run our code

# This is the base image we want to use for our production
# build
FROM public.ecr.aws/nginx/nginx

# Copy the built files onto our image
COPY --from=build /my-app/build /usr/share/nginx/html

# Expose port 80 to be accessed via HTTP
EXPOSE 80

# Start up the NGINX server
CMD ["nginx", "-g", "daemon off;"]
