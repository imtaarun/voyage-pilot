import { Model, AllowNull, AutoIncrement, Column, DataType, HasMany, PrimaryKey, Table, ForeignKey, BelongsTo } from "sequelize-typescript";
import { Trip } from './trip.model';
import { Activity } from './activity.model';

@Table({
  tableName: 'TripDays',
  timestamps: true,
})
export class TripDay extends Model {
  @PrimaryKey
  @AutoIncrement
  @Column(DataType.INTEGER)
  id!: number;

  @ForeignKey(() => Trip)
  @AllowNull(false)
  @Column(DataType.INTEGER)
  tripId!: number;

  @BelongsTo(() => Trip)
  trip!: Trip;

  @AllowNull(false)
  @Column(DataType.DATEONLY)
  date!: string; // DATEONLY is typically represented as a string in JS

  @Column(DataType.TEXT)
  notes?: string; // Optional as it's not allowNull: false in migration

  @HasMany(() => Activity)
  activities?: Activity[];
}