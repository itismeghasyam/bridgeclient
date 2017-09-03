from setuptools import setup

setup(name='bridgeclient',
      version='0.1',
      description='Convenience functions for dealing with Bridge server',
      url='https://github.com/Sage-Bionetworks/bridgepythonclient',
      author='Larson Omberg',
      author_email='larsson.omberg@sagebase.org',
      license='Apache',
      packages=['bridgeclient'],
      install_requires=[
          'synapseclient',
          'pandas'],
      zip_safe=False)
