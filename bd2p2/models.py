# coding: utf-8
from sqlalchemy import Column, ForeignKey, Integer, String, TIMESTAMP, text
from sqlalchemy.dialects.mysql import SMALLINT
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()
metadata = Base.metadata


class User(Base):
  __tablename__ = 'user'

  id = Column(Integer, primary_key=True, autoincrement=True, nullable=False)
  name = Column(String(50))
  age = Column(Integer)
  email = Column(String(50), unique=True)


class Country(Base):
  __tablename__ = 'country'

  country_id = Column(SMALLINT(5), primary_key=True)
  country = Column(String(50), nullable=False)
  last_update = Column(TIMESTAMP, nullable=False, server_default=text(
      "current_timestamp() ON UPDATE current_timestamp()"))

  def __str__(self):
    return f"| country_id: {self.country_id:3} | country_name: {self.country:38}| last update: {self.last_update} |"


class City(Base):
  __tablename__ = 'city'

  city_id = Column(SMALLINT(5), primary_key=True)
  city = Column(String(50), nullable=False)
  country_id = Column(ForeignKey('country.country_id', onupdate='CASCADE'), nullable=False, index=True)
  last_update = Column(TIMESTAMP, nullable=False, server_default=text(
      "current_timestamp() ON UPDATE current_timestamp()"))

  country = relationship('Country')

  def __str__(self):
    return f"| city_id: {self.city_id:3} | city_name: {self.city:27}| country_name: {self.country.country:38}| last update: {self.last_update} |"
