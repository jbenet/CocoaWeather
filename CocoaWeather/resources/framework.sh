                 FRAMEWORK_NAME=CocoaWeather
              FRAMEWORK_VERSION=A
      FRAMEWORK_CURRENT_VERSION=1
FRAMEWORK_COMPATIBILITY_VERSION=1
                     BUILD_TYPE=Release


FRAMEWORK_BUILD_PATH="build/Framework"
FRAMEWORK_DIR=$FRAMEWORK_BUILD_PATH/$FRAMEWORK_NAME.framework


echo "Framework: Cleaning framework..."
rm -rf $FRAMEWORK_DIR/*

# Build the canonical Framework bundle directory structure
echo "Framework: Setting up directories..."
mkdir -p $FRAMEWORK_DIR
mkdir -p $FRAMEWORK_DIR/Versions
mkdir -p $FRAMEWORK_DIR/Versions/$FRAMEWORK_VERSION
mkdir -p $FRAMEWORK_DIR/Versions/$FRAMEWORK_VERSION/Resources
mkdir -p $FRAMEWORK_DIR/Versions/$FRAMEWORK_VERSION/Headers

echo "Framework: Creating symlinks..."
ln -s $FRAMEWORK_VERSION $FRAMEWORK_DIR/Versions/Current
ln -s Versions/Current/Headers $FRAMEWORK_DIR/Headers
ln -s Versions/Current/Resources $FRAMEWORK_DIR/Resources
ln -s Versions/Current/$FRAMEWORK_NAME $FRAMEWORK_DIR/$FRAMEWORK_NAME

# Check that this is what your static libraries are called
FRAMEWORK_INPUT_ARM_FILES="build/$BUILD_TYPE-iphoneos/libCocoaWeather.a"
FRAMEWORK_INPUT_I386_FILES="build/$BUILD_TYPE-iphonesimulator/libCocoaWeather.a"

# to use lipo to glue the different library versions together into one library
echo "Framework: Creating library..."
lipo \
  -create \
  "$FRAMEWORK_INPUT_ARM_FILES" \
  -arch i386 "$FRAMEWORK_INPUT_I386_FILES" \
  -o "$FRAMEWORK_DIR/Versions/Current/$FRAMEWORK_NAME"

# Copy assets into framework structure.
echo "Framework: Copying assets into current version..."
cp include/$FRAMEWORK_NAME/* $FRAMEWORK_DIR/Headers/
cp Resources/Framework.plist $FRAMEWORK_DIR/Resources/Info.plist
